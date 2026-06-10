import 'package:mixcine_movie_app/domain/entities/payment_plan.dart';

abstract class PaymentRepository {
  /// Lấy link thanh toán cho một gói cước cụ thể
  Future<String> generatePaymentUrl(PaymentPlan plan);

  /// Xác nhận thanh toán từ response của cổng thanh toán và cập nhật gói cước cho user
  Future<bool> verifyAndProcessPayment({
    required Map<String, dynamic> paymentResult,
    required PaymentPlan plan,
    required String userId,
  });
}
