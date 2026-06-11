import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../notification/notification_screen.dart';
import '../../../core/config/app_branding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/payment_plan.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/branded_screen_header.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final favorites =
        ref.watch(favoriteMoviesProvider).value ?? const <dynamic>[];

    // 🚀 Theo dõi trạng thái Theme hiện tại
    final themeMode = ref.watch(themeProvider);
    final currentIsDark = themeMode == ThemeMode.dark;

    // 🚀 Logic xác định gói cước và huy hiệu
    final subscription = ref.watch(subscriptionProvider);
    final isPremium =
        subscription?.isActive == true &&
        subscription?.plan == PaymentPlan.vipPro;
    final isVip =
        subscription?.isActive == true && subscription?.plan == PaymentPlan.vip;

    String planName = 'Cày chay (Free)';
    Color planColor = isDark ? Colors.grey : Colors.grey.shade600;

    if (isPremium) {
      planName = 'Vippro 4K';
      planColor = Colors.purpleAccent;
    } else if (isVip) {
      planName = 'VIP 720p';
      planColor = Colors.orangeAccent;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandedScreenHeader(
                title: 'Hồ sơ',
                subtitle: 'Quản lý tài khoản và thiết lập cá nhân.',
              ),
              const SizedBox(height: 28),

              // --- CARD THÔNG TIN NGƯỜI DÙNG ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : colorScheme.outline.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // =======================================================================
                    // KHUNG TRÒN HIỂN THỊ AVATAR ĐÃ ĐỒNG BỘ REALTIME TỪ DATABASE
                    // =======================================================================
                    // Thay phần CircleAvatar trong ProfileScreen
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      backgroundImage:
                          (user?.avatar != null && user!.avatar!.isNotEmpty)
                          ? NetworkImage(
                              "${user!.avatar!}?t=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                      child: (user?.avatar == null || user!.avatar!.isEmpty)
                          ? Icon(
                              Icons.person_rounded,
                              size: 38,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? user?.email ?? 'Người dùng',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Chưa cập nhật email',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Huy hiệu gói cước tinh tế
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: planColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: planColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              planName,
                              style: TextStyle(
                                color: planColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- GRID TIỆN ÍCH: YÊU THÍCH & ĐỔI THEME ---
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Yêu thích',
                      value: '${favorites.length}',
                      icon: Icons.favorite_rounded,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Giao diện',
                      value: currentIsDark ? 'Tối' : 'Sáng',
                      icon: currentIsDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      accentColor: Colors.blueAccent,
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Text(
                'Cài đặt',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- DANH SÁCH MENU TIỆN ÍCH ---
              _ProfileTile(
                icon: Icons.edit_note_rounded,
                title: 'Chỉnh sửa hồ sơ',
                onTap: () => context.push('/edit-profile'),
              ),

              _ProfileTile(
                icon: Icons.notifications_active_outlined,
                title: 'Thông báo',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
              ),
              _ProfileTile(
                icon: Icons.info_outline_rounded,
                title: 'Về Mixcine',
                subtitle: AppBranding.aboutLine,
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Đăng xuất',
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
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
    required this.accentColor,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null && subtitle!.isNotEmpty
            ? Text(
                subtitle!,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
        ),
      ),
    );
  }
}
