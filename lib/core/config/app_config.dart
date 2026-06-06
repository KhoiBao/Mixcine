class AppConfig {
  const AppConfig._();

  static const bool useMockData = true; 
  // mockdata = true: using already equipped film
  // mockdata = false: using real API data, configure API key in ApiConfig
  static const int pageSize = 6;

  static const String demoVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  static const String fallbackPosterUrl =
      'https://picsum.photos/seed/mixcine_fallback_poster/500/750';
  static const String fallbackBackdropUrl =
      'https://picsum.photos/seed/mixcine_fallback_backdrop/1200/700';
}
