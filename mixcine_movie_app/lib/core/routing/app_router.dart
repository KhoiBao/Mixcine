import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/player/video_player_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return MovieDetailScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return VideoPlayerScreen(movieId: movieId);
        },
      ),
    ],
  );
});
