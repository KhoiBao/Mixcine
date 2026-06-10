import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/subscription_local_data_source.dart';
import '../../data/models/subscription_model.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Chưa khởi tạo SharedPreferences');
});

final subscriptionLocalDataSourceProvider = Provider<SubscriptionLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SubscriptionLocalDataSource(prefs);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionModel?> {
  final SubscriptionLocalDataSource _localDataSource;

  SubscriptionNotifier(this._localDataSource) : super(null) {
    _loadSubscription();
  }

  void _loadSubscription() {
    state = _localDataSource.getSubscription();
  }

  // HÀM QUAN TRỌNG: Để cập nhật UI ngay lập tức sau khi mua
  void setSubscription(SubscriptionModel subscription) {
    state = subscription;
  }

  Future<void> refreshSubscription() async {
    _loadSubscription();
  }

  void clear() {
    state = null;
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionModel?>((ref) {
  final dataSource = ref.watch(subscriptionLocalDataSourceProvider);
  return SubscriptionNotifier(dataSource);
});
