import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Nhớ import file model của bro ở đây nhé
import '../models/subscription_model.dart';

class SubscriptionLocalDataSource {
  SubscriptionLocalDataSource(this.prefs);

  final SharedPreferences prefs;
  static const String _subscriptionKey = 'current_user_subscription';

  /// Lưu thông tin gói cước vào local storage
  Future<void> saveSubscription(SubscriptionModel subscription) async {
    final jsonString = json.encode(subscription.toJson());
    await prefs.setString(_subscriptionKey, jsonString);
  }

  /// Lấy thông tin gói cước từ local storage
  SubscriptionModel? getSubscription() {
    final jsonString = prefs.getString(_subscriptionKey);
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return SubscriptionModel.fromJson(jsonMap);
      } catch (e) {
        // Có thể log error ra đây nếu parse xịt
        return null;
      }
    }
    return null;
  }

  /// Xóa thông tin gói cước (dùng khi user đăng xuất hoặc hết hạn)
  Future<void> clearSubscription() async {
    await prefs.remove(_subscriptionKey);
  }
}
