import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/payment_plan.dart';
import 'subscription_provider.dart'; // Đảm bảo bro đã có file này ở Giai đoạn 3 nhé

class ContentAccessHelper {
  final PaymentPlan currentPlan;
  final bool isSubscriptionActive;

  ContentAccessHelper({
    required this.currentPlan,
    required this.isSubscriptionActive,
  });

  /// Logic check quyền xem dựa trên thông số gói cước
  bool get canWatch4K => isSubscriptionActive && currentPlan.maxResolution == '4K';
  bool get canWatch720p => isSubscriptionActive && (currentPlan.maxResolution == '720p' || currentPlan.maxResolution == '4K');
  bool get canDownloadOffline => isSubscriptionActive && currentPlan.allowOfflineDownload;
  bool get showAds => !isSubscriptionActive || currentPlan.hasAds;
}

// Provider tự động lắng nghe trạng thái gói cước (subscriptionProvider)
final contentAccessProvider = Provider<ContentAccessHelper>((ref) {
  final subscription = ref.watch(subscriptionProvider);

  // Nếu user có mua gói và gói đang Active
  if (subscription != null && subscription.isActive) {
    return ContentAccessHelper(
      currentPlan: subscription.plan,
      isSubscriptionActive: true,
    );
  }

  // Mặc định nếu chưa mua gì thì rớt về gói FREE
  return ContentAccessHelper(
    currentPlan: PaymentPlan.free,
    isSubscriptionActive: false,
  );
});