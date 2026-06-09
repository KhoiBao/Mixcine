import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_branding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/payment_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/branded_screen_header.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final favorites =
        ref.watch(favoriteMoviesProvider).value ?? const <dynamic>[];

    // 🚀 LOGIC LẤY THÔNG TIN GÓI CƯỚC ĐỂ VẼ HUY HIỆU
    final subscription = ref.watch(subscriptionProvider);
    final isPremium = subscription?.isActive == true && subscription?.plan == PaymentPlan.vipPro;
    final isVip = subscription?.isActive == true && subscription?.plan == PaymentPlan.vip;

    String planName = 'Cày chay (Free)';
    Color planColor = Colors.grey;

    if (isPremium) {
      planName = 'Vippro 4K';
      planColor = Colors.purpleAccent; // Màu tím hoàng gia cho Vippro
    } else if (isVip) {
      planName = 'VIP 720p';
      planColor = Colors.orangeAccent; // Màu cam cháy cho VIP
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const BrandedScreenHeader(
              title: 'Profile',
              subtitle: 'Account, preferences, and demo settings.',
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 34,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user?.fullName ?? user?.email ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phoneNumber ?? 'No phone',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        // 🚀 HUY HIỆU CẤP BẬC HIỂN THỊ TẠI ĐÂY
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: planColor.withOpacity(0.2),
                            border: Border.all(color: planColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            planName,
                            style: TextStyle(
                              color: planColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    label: 'Favorites',
                    value: '${favorites.length}',
                    icon: Icons.favorite,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _StatCard(
                    label: 'Theme',
                    value: 'Dark',
                    icon: Icons.dark_mode_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _ProfileTile(
              icon: Icons.person_outline,
              title: 'Edit profile',
              subtitle: '',
              onTap: () => context.push('/edit-profile'),
            ),
            const _ProfileTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: '',
            ),
            const _ProfileTile(
              icon: Icons.info_outline,
              title: 'Về app',
              subtitle: AppBranding.aboutLine,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Đăng xuất',
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}