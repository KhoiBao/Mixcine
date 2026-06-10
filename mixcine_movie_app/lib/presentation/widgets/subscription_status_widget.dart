import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';

class SubscriptionStatusWidget extends ConsumerWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final isActive = subscription?.isActive ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isActive ? Icons.stars : Icons.stars_outlined,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isActive ? 'Gói ${subscription!.plan.displayName}' : 'Gói Miễn Phí',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isActive ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isActive)
                  Text(
                    'Hết hạn: ${subscription!.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  Text(
                    'Nâng cấp để xem phim không giới hạn',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (!isActive)
            ElevatedButton(
              onPressed: () => context.push('/subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Nâng cấp'),
            ),
        ],
      ),
    );
  }
}