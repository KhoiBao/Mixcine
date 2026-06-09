import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import đúng đường dẫn của bro nhé (dựa theo cấu trúc Clean Architecture của app)
import '../../data/datasources/subscription_local_data_source.dart';
import '../../data/models/subscription_model.dart';

// 1. Provider cung cấp SharedPreferences (Sẽ được override lúc chạy app ở main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Chưa khởi tạo SharedPreferences');
});

// 2. Provider cung cấp Local Data Source để lấy cache gói cước
final subscriptionLocalDataSourceProvider = Provider<SubscriptionLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SubscriptionLocalDataSource(prefs);
});

// 3. Notifier quản lý trạng thái gói cước hiện tại của user
class SubscriptionNotifier extends StateNotifier<SubscriptionModel?> {
  final SubscriptionLocalDataSource _localDataSource;

  SubscriptionNotifier(this._localDataSource) : super(null) {
    _loadSubscription();
  }

  // Load gói cước từ cache lên khi mở app
  void _loadSubscription() {
    state = _localDataSource.getSubscription();
  }

  // Cập nhật lại UI lập tức sau khi thanh toán VNPAY thành công
  Future<void> refreshSubscription() async {
    _loadSubscription();
  }
}

// 4. ĐÂY CHÍNH LÀ PROVIDER MÀ CÁC FILE KHÁC ĐANG ĐÒI IMPORT NÈ BRO:
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionModel?>((ref) {
  final dataSource = ref.watch(subscriptionLocalDataSourceProvider);
  return SubscriptionNotifier(dataSource);
});