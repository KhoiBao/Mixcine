import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import '../../core/config/key.dart';

class VnpayService {
  // Bro thay bằng Key lấy từ email đăng ký VNPAY Sandbox nhé
  final String _tmnCode = vnpTmnCode;
  final String _hashSecret = vnpHashSecret;
  final String _vnpUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

  // Đường dẫn app của bro để VNPAY đá về sau khi thanh toán xong (Deep link)
  final String _returnUrl = "mixcine://payment-result";

  /// Tạo link thanh toán VNPAY thật
  Future<String> createPaymentUrl({
    required int amount,
    required String orderInfo,
  }) async {
    final DateTime now = DateTime.now();
    final String createDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String expireDate = DateFormat(
      'yyyyMMddHHmmss',
    ).format(now.add(const Duration(minutes: 15)));

    // Tự gen ra một mã giao dịch ngẫu nhiên cho hệ thống của mình
    final String txnRef = "${now.millisecondsSinceEpoch}";

    Map<String, String> vnpParams = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': _tmnCode,
      'vnp_Locale': 'vn',
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_Amount': (amount * 100).toString(), // VNPAY yêu cầu nhân 100
      'vnp_ReturnUrl': _returnUrl,
      'vnp_IpAddr': '127.0.0.1', // Thực tế nên lấy IP thật của thiết bị
      'vnp_CreateDate': createDate,
      'vnp_ExpireDate': expireDate,
    };

    // 1. Sắp xếp các tham số theo thứ tự alphabet (Bắt buộc của VNPAY)
    final sortedParams = Map.fromEntries(
      vnpParams.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    // 2. Tạo chuỗi query string
    final queryString = Uri(queryParameters: sortedParams).query;

    // 3. Mã hóa tạo chữ ký (Secure Hash) bằng HMAC SHA512
    var bytes = utf8.encode(_hashSecret);
    var hmacSha512 = Hmac(sha512, bytes);
    var digest = hmacSha512.convert(utf8.encode(queryString));
    String secureHash = digest.toString();

    // 4. Ghép chữ ký vào cuối URL
    final String finalUrl = "$_vnpUrl?$queryString&vnp_SecureHash=$secureHash";

    return finalUrl;
  }

  /// Xác minh chữ ký trả về từ VNPAY (Chống hacker sửa link)
  Future<bool> verifyPayment(Map<String, String> responseParams) async {
    final vnpSecureHash = responseParams['vnp_SecureHash'];
    responseParams.remove('vnp_SecureHash');
    responseParams.remove('vnp_SecureHashType');

    final sortedParams = Map.fromEntries(
      responseParams.entries.toList()
        ..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    final signData = Uri(queryParameters: sortedParams).query;
    var bytes = utf8.encode(_hashSecret);
    var hmacSha512 = Hmac(sha512, bytes);
    var digest = hmacSha512.convert(utf8.encode(signData));
    String checkSum = digest.toString();

    // Nếu mã tự tính khớp với mã VNPAY trả về -> Giao dịch chuẩn
    if (checkSum == vnpSecureHash &&
        responseParams['vnp_ResponseCode'] == '00') {
      return true;
    }
    return false;
  }
}
