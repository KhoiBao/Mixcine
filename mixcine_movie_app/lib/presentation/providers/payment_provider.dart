import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import các file cấu hình và logic
import '../../core/services/vnpay_service.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_plan.dart';
import '../../data/repositories/payment_repository.dart';

// Import Provider của subscription để update lại UI sau khi mua xong
import 'subscription_provider.dart';

// 1. Khởi tạo VnpayService
final vnpayServiceProvider = Provider<VnpayService>((ref) {
  return VnpayService();
});

// 2. Khởi tạo PaymentRepository
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final vnpayService = ref.watch(vnpayServiceProvider);
  final localDataSource = ref.watch(subscriptionLocalDataSourceProvider);

  return PaymentRepositoryImpl(
    vnpayService: vnpayService,
    localDataSource: localDataSource,
  );
});

// 3. Notifier xử lý luồng thanh toán (Loading, Success, Error)
class PaymentNotifier extends StateNotifier<AsyncValue<void>> {
  final PaymentRepository _repository;
  final Ref _ref;

  PaymentNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Hàm gọi API VNPAY để tạo link thanh toán dựa trên gói cước
  Future<String?> getPaymentUrl(PaymentPlan plan) async {
    state = const AsyncValue.loading(); // Xoay vòng loading trên UI
    try {
      final url = await _repository.generatePaymentUrl(plan);
      state = const AsyncValue.data(null); // Tắt loading
      return url;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Hàm xử lý kết quả trả về từ URL redirect của VNPAY
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
        // Nếu thanh toán thành công, ra lệnh cho subscriptionProvider update lại dữ liệu
        await _ref.read(subscriptionProvider.notifier).refreshSubscription();
      }

      state = const AsyncValue.data(null);
      return isSuccess;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

// 4. Provider để UI (SubscriptionScreen & PaymentScreen) gọi tới
final paymentProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository, ref);
});