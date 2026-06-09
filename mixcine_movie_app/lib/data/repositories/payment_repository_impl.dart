import 'package:mixcine_movie_app/core/services/vnpay_service.dart';
import 'package:mixcine_movie_app/data/datasources/subscription_local_data_source.dart';
import 'package:mixcine_movie_app/data/datasources/auth_remote_data_source.dart';
import 'package:mixcine_movie_app/data/models/subscription_model.dart';
import 'package:mixcine_movie_app/domain/entities/payment_plan.dart';
import 'package:mixcine_movie_app/data/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final VnpayService vnpayService;
  final SubscriptionLocalDataSource localDataSource;
  final AuthRemoteDataSource authDataSource = AuthRemoteDataSource();

  PaymentRepositoryImpl({
    required this.vnpayService,
    required this.localDataSource,
  });

  @override
  Future<String> generatePaymentUrl(PaymentPlan plan) async {
    try {
      final url = await vnpayService.createPaymentUrl(
        amount: plan.priceVnd,
        orderInfo: 'Thanh toan goi ${plan.displayName}',
      );
      return url;
    } catch (e) {
      throw Exception('Không thể tạo link thanh toán: $e');
    }
  }

  @override
  Future<bool> verifyAndProcessPayment({
    required Map<String, dynamic> paymentResult,
    required PaymentPlan plan,
    required String userId,
  }) async {
    try {
      print('--- [BẮT ĐẦU XỬ LÝ THANH TOÁN] ---');
      print('User: $userId | Plan: ${plan.id}');

      final String responseCode = paymentResult['vnp_ResponseCode']?.toString() ?? '';
      
      // LOGIC "CỬA HẬU" ĐỂ TEST: Nếu là Skip (TransactionNo = 999999) thì ép thành true luôn
      bool isVerified = false;
      if (paymentResult['vnp_TransactionNo'] == '999999') {
        print('--- PHÁT HIỆN LỆNH SKIP: ÉP KÍCH HOẠT VIP ---');
        isVerified = true; 
      } else {
        final Map<String, String> stringParams = paymentResult.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        isVerified = await vnpayService.verifyPayment(stringParams);
      }

      if (isVerified && responseCode == '00') {
        // 1. Lưu vào SharedPreferences cho nhanh
        final newSubscription = SubscriptionModel(
          userId: userId,
          plan: plan,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          paymentMethod: 'VNPAY_BYPASS',
        );
        await localDataSource.saveSubscription(newSubscription);

        // 2. CẬP NHẬT DATABASE THẬT (Dùng Email để tìm user)
        // Ép ID gói thành chữ HOA (VIP, VIP_PRO) cho khớp với Enum
        final standardPlanId = plan.id.toUpperCase();
        await authDataSource.updateUserPlan(userId, standardPlanId); 
        
        print('--- [DATABASE] ĐÃ CẬP NHẬT GÓI $standardPlanId CHO $userId ---');
        return true;
      }
      
      print('--- [XÁC THỰC THẤT BẠI] Chữ ký hoặc ResponseCode không hợp lệ ---');
      return false;
    } catch (e) {
      print('--- [LỖI NGHIÊM TRỌNG] $e ---');
      return false;
    }
  }
}
