import '../../domain/entities/payment_plan.dart';

/// Model cho gói cước (đăng ký) của user
class SubscriptionModel {
  const SubscriptionModel({
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.transactionId,
    this.paymentMethod,
  });

  /// ID của user
  final String userId;

  /// Gói cước hiện tại
  final PaymentPlan plan;

  /// Ngày bắt đầu gói
  final DateTime startDate;

  /// Ngày kết thúc gói (hết hạn)
  final DateTime endDate;

  /// Gói còn hiệu lực không
  final bool isActive;

  /// ID giao dịch thanh toán (từ VNPAY, v.v.)
  final String? transactionId;

  /// Phương thức thanh toán (VNPAY, MOMO, v.v.)
  final String? paymentMethod;

  /// Tính số ngày còn lại
  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Gói sắp hết hạn không (< 7 ngày)
  bool get isExpiringSoon {
    return daysRemaining > 0 && daysRemaining <= 7;
  }

  /// Tạo từ JSON
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      userId: json['userId'] as String? ?? '',
      plan: PaymentPlan.fromId(json['plan'] as String? ?? 'FREE'),
      startDate: DateTime.parse(
        json['startDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] as bool? ?? true,
      transactionId: json['transactionId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  /// Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'plan': plan.id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
    };
  }

  /// Copy with
  SubscriptionModel copyWith({
    String? userId,
    PaymentPlan? plan,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? transactionId,
    String? paymentMethod,
  }) {
    return SubscriptionModel(
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() =>
      'SubscriptionModel(userId: $userId, plan: ${plan.displayName}, endDate: $endDate, daysRemaining: $daysRemaining)';
}
