import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';

class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this.prefs);

  final SharedPreferences prefs;
  
  // Tạo key riêng cho từng User dựa trên ID
  String _getKey(String userId) => 'subscription_user_$userId';

  /// Lưu thông tin gói cước vào local storage theo User ID
  Future<void> saveSubscription(SubscriptionModel subscription) async {
    final jsonString = json.encode(subscription.toJson());
    await prefs.setString(_getKey(subscription.userId), jsonString);
  }

  /// Lấy thông tin gói cước của đúng User đó
  SubscriptionModel? getSubscription(String? userId) {
    if (userId == null) return null;
    
    final jsonString = prefs.getString(_getKey(userId));
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return SubscriptionModel.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Xóa thông tin gói (thường dùng khi hết hạn)
  Future<void> clearSubscription(String userId) async {
    await prefs.remove(_getKey(userId));
  }
}
