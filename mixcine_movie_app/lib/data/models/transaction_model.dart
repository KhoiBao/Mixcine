/// Model cho lịch sử giao dịch thanh toán
class TransactionModel {
  const TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.planId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.vnpayTransactionNo,
  });

  /// ID giao dịch (do hệ thống của mình tạo ra)
  final String transactionId;

  /// ID của user thực hiện giao dịch
  final String userId;

  /// ID của gói cước (FREE, VIP, VIP_PRO)
  final String planId;

  /// Số tiền thanh toán (VND)
  final int amount;

  /// Trạng thái: 'PENDING', 'SUCCESS', 'FAILED'
  final String status;

  /// Thời gian tạo giao dịch
  final DateTime createdAt;

  /// Mã giao dịch trả về từ VNPAY (nếu có)
  final String? vnpayTransactionNo;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      vnpayTransactionNo: json['vnpayTransactionNo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'planId': planId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'vnpayTransactionNo': vnpayTransactionNo,
    };
  }
}
