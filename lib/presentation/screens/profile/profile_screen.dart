import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_branding.dart';
import '../../providers/app_providers.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/branded_screen_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteMoviesProvider).value ?? const <dynamic>[];

    // Lắng nghe ThemeMode hiện tại
    final themeModeAsync = ref.watch(themeModeProvider);
    final isDark =
        (themeModeAsync.value ?? ThemeMode.dark) == ThemeMode.dark;

    // Lấy màu từ Theme hiện tại để UI tương thích cả 2 mode
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final primaryColor = colorScheme.primary;

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
            // ── Avatar & thông tin ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(Icons.person_outline, size: 34, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Người Tày', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Sinh viên lớp LTDĐ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Thống kê nhanh ──
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
                Expanded(
                  child: _StatCard(
                    label: 'Theme',
                    value: isDark ? 'Dark' : 'Light',
                    icon: isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // ── Nút chuyển đổi Dark / Light Mode ──
            _ThemeToggleTile(isDark: isDark),
            const _ProfileTile(icon: Icons.person_outline, title: 'Edit profile', subtitle: ''),
            const _ProfileTile(icon: Icons.notifications_none, title: 'Notifications', subtitle: ''),
            const _ProfileTile(icon: Icons.info_outline, title: 'Về app', subtitle: AppBranding.aboutLine),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile chuyển đổi Dark / Light Mode với Switch.
// ---------------------------------------------------------------------------

class _ThemeToggleTile extends ConsumerWidget {
  const _ThemeToggleTile({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: primaryColor,
        ),
        title: const Text('Dark Mode'),
        subtitle: Text(isDark ? 'Đang bật' : 'Đang tắt'),
        trailing: Switch.adaptive(
          value: isDark,
          activeThumbColor: primaryColor,
          onChanged: (_) {
            // Gọi toggle – tự động lưu SharedPreferences
            ref.read(themeModeProvider.notifier).toggle();
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets nội bộ giữ nguyên phong cách gốc.
// ---------------------------------------------------------------------------

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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: primaryColor),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

