import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_branding.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_startFlow);
  }

  Future<void> _startFlow() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Check if user is already logged in
    final authState = ref.read(authStateProvider);
    final hasSeenOnboarding = await ref
        .read(appPreferencesProvider)
        .hasSeenOnboarding();

    if (!mounted) {
      return;
    }

    // Navigation logic: auth -> dashboard, no auth && onboarded -> login, no auth && not onboarded -> onboarding
    if (authState.token != null) {
      // User is logged in, go to dashboard
      context.go('/dashboard');
    } else if (hasSeenOnboarding) {
      // User has seen onboarding but not logged in, go to login
      context.go('/login');
    } else {
      // First time user, show onboarding
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.background, AppColors.surface],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppBranding.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppBranding.splashTagline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
