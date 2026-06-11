import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mixcine_movie_app/presentation/providers/auth_provider.dart';
import 'package:mixcine_movie_app/domain/entities/payment_plan.dart';

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
  final String? _userId;

  SubscriptionNotifier(this._localDataSource, this._userId) : super(null) {
    _loadSubscription();
  }

  void _loadSubscription() {
    if (_userId != null) {
      state = _localDataSource.getSubscription(_userId);
    } else {
      state = null;
    }
  }

  // Đồng bộ gói cước từ DB Supabase vào local
  void syncWithUserPlan(String? planId) {
    if (_userId == null || planId == null || planId == 'FREE') {
      state = null;
      return;
    }
    
    // Nếu local chưa có hoặc khác gói trên DB thì cập nhật lại local
    if (state == null || state!.plan.id != planId) {
      final newSub = SubscriptionModel(
        userId: _userId!,
        plan: PaymentPlan.fromId(planId),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );
      setSubscription(newSub);
    }
  }

  void setSubscription(SubscriptionModel subscription) {
    state = subscription;
    _localDataSource.saveSubscription(subscription);
  }

  Future<void> refreshSubscription() async {
    _loadSubscription();
  }

  void clear() {
    if (_userId != null) {
      _localDataSource.clearSubscription(_userId!);
    }
    state = null;
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionModel?>((ref) {
  final dataSource = ref.watch(subscriptionLocalDataSourceProvider);
  // Lấy userId từ authStateProvider để notifier biết đang load cho ai
  final userId = ref.watch(authStateProvider.select((s) => s.user?.id));
  return SubscriptionNotifier(dataSource, userId);
});
