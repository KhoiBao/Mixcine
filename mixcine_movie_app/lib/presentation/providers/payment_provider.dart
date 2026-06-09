import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/vnpay_service.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_plan.dart';
import '../../data/repositories/payment_repository.dart';

import 'subscription_provider.dart';
import 'auth_provider.dart';
import 'content_access_provider.dart';

// 1. Khởi tạo Service chuẩn
final vnpayServiceProvider = Provider<VnpayService>((ref) {
  return VnpayService();
});

// 2. Khởi tạo Repository chuẩn
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final vnpayService = ref.watch(vnpayServiceProvider);
  final localDataSource = ref.watch(subscriptionLocalDataSourceProvider);

  return PaymentRepositoryImpl(
    vnpayService: vnpayService,
    localDataSource: localDataSource,
  );
});

class PaymentNotifier extends StateNotifier<AsyncValue<void>> {
  final PaymentRepository _repository;
  final Ref _ref;

  PaymentNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> getPaymentUrl(PaymentPlan plan) async {
    state = const AsyncValue.loading();
    try {
      final url = await _repository.generatePaymentUrl(plan);
      state = const AsyncValue.data(null);
      return url;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> processPaymentResult({
    required Map<String, dynamic> result,
    required PaymentPlan plan,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final isSuccess = await _repository.verifyAndProcessPayment(
        paymentResult: result,
        plan: plan,
        userId: userId,
      );

      if (isSuccess) {
        // --- BƯỚC QUAN TRỌNG NHẤT ĐỂ VIP ĂN NGAY ---
        
        // 1. Load lại User từ Database (để lấy cột plan mới)
        await _ref.read(authStateProvider.notifier).reloadUserFromDb();
        
        // 2. Load lại cache subscription
        await _ref.read(subscriptionProvider.notifier).refreshSubscription();
        
        // 3. Ép ContentAccessProvider tính toán lại quyền lợi xem phim
        _ref.invalidate(contentAccessProvider);
        
        print('--- CHÚC MỪNG BRO! ĐÃ KÍCH HOẠT VIP THÀNH CÔNG TRÊN UI ---');
      }

      state = const AsyncValue.data(null);
      return isSuccess;
    } catch (e, st) {
      print('Lỗi processPaymentResult: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository, ref);
});
