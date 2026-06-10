import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_plan.dart';
import 'subscription_provider.dart';
import 'auth_provider.dart';

class ContentAccessHelper {
  final PaymentPlan currentPlan;
  final bool isSubscriptionActive;

  ContentAccessHelper({
    required this.currentPlan,
    required this.isSubscriptionActive,
  });

  int get userTier {
    if (!isSubscriptionActive) return 1;
    final planId = currentPlan.id.toUpperCase();
    if (planId == 'VIP_PRO') return 3;
    if (planId == 'VIP') return 2;
    return 1;
  }

  bool get canWatch4K => userTier >= 3;
  bool get canWatch720p => userTier >= 2;
  bool get canDownloadOffline => isSubscriptionActive && currentPlan.allowOfflineDownload;
  bool get showAds => userTier < 3;
}

final contentAccessProvider = Provider<ContentAccessHelper>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  final authState = ref.watch(authStateProvider);
  
  print('--- [CHECK QUYỀN TRUY CẬP] ---');

  // 1. Kiểm tra từ cache Subscription
  if (subscription != null && subscription.isActive) {
    print('Phát hiện gói cước từ cache: ${subscription.plan.id}');
    return ContentAccessHelper(
      currentPlan: subscription.plan,
      isSubscriptionActive: true,
    );
  }

  // 2. Kiểm tra từ Database (Auth State)
  final userPlanId = authState.user?.plan;
  if (userPlanId != null) {
    print('Phát hiện gói cước từ Database: $userPlanId');
    final plan = PaymentPlan.fromId(userPlanId);
    if (plan != PaymentPlan.free) {
      return ContentAccessHelper(
        currentPlan: plan,
        isSubscriptionActive: true,
      );
    }
  }

  print('Không tìm thấy gói VIP. Đang dùng gói: FREE');
  return ContentAccessHelper(
    currentPlan: PaymentPlan.free,
    isSubscriptionActive: false,
  );
});
