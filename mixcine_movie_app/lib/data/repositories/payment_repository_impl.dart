import 'package:mixcine_movie_app/core/services/vnpay_service.dart';
import 'package:mixcine_movie_app/data/datasources/subscription_local_data_source.dart';
import 'package:mixcine_movie_app/data/models/subscription_model.dart';
import 'package:mixcine_movie_app/domain/entities/payment_plan.dart';
import 'package:mixcine_movie_app/data/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final VnpayService vnpayService;
  final SubscriptionLocalDataSource localDataSource;

  PaymentRepositoryImpl({
    required this.vnpayService,
    required this.localDataSource,
  });

  @override
  Future<String> generatePaymentUrl(PaymentPlan plan) async {
    try {
      // Gọi service để tạo link với giá tiền của gói
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
      // 1. Ép kiểu Map<String, dynamic> thành Map<String, String>
      final Map<String, String> stringParams = paymentResult.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      // Truyền stringParams đã ép kiểu vào VNPAY Service
      final isSuccess = await vnpayService.verifyPayment(stringParams);

      if (isSuccess) {
        // 2. Nếu thành công, tạo model Subscription mới (ví dụ hạn 30 ngày)
        final newSubscription = SubscriptionModel(
          userId: userId,
          plan: plan,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          paymentMethod: 'VNPAY',
        );

        // 3. Lưu vào Local Storage (và thực tế là sẽ gọi API lưu lên Backend nữa)
        await localDataSource.saveSubscription(newSubscription);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
