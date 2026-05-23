import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const <_OnboardingItem>[
    _OnboardingItem(
      icon: Icons.movie_filter_outlined,
      title: 'Browse movies fast',
      subtitle: 'Explore curated sections, discover titles, and open details with a clean dark UI.',
    ),
    _OnboardingItem(
      icon: Icons.favorite_outline,
      title: 'Save your favorites',
      subtitle: 'Keep a personal list locally on the device and revisit it later anytime.',
    ),
    _OnboardingItem(
      icon: Icons.ondemand_video_outlined,
      title: 'Play sample trailers',
      subtitle: 'Open a simple video player screen and continue the full movie app flow.',
    ),
  ];

  Future<void> _finish() async {
    await ref.read(appPreferencesProvider).setHasSeenOnboarding(true);
    if (!mounted) {
      return;
    }
    context.go('/dashboard');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _items.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Icon(item.icon, size: 96, color: AppColors.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: isLastPage ? 'Get started' : 'Next',
                icon: isLastPage ? Icons.rocket_launch_outlined : Icons.arrow_forward_rounded,
                onPressed: () async {
                  if (isLastPage) {
                    await _finish();
                    return;
                  }
                  await _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
