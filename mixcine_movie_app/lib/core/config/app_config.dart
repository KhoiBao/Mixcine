class AppConfig {
  const AppConfig._();

  static const bool useMockData = true;
  // mockdata = true: using already equipped film
  // mockdata = false: using real API data, configure API key in ApiConfig
  static const int pageSize = 6;
  
  // Supabase config
  // Project Ref: hpwikwzekjnzhtxheoes
  static const String supabaseUrl = 'https://hpwikwzekjnzhtxheoes.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhwd2lrd3pla2puemh0eGhlb2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMDIxMzksImV4cCI6MjA5NjY3ODEzOX0.ur5wHRrvyQx23kNrEThK-CdmOOL4UKGKp8aIQJa4AVw';

  static const String demoVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  static const String fallbackPosterUrl =
      'https://picsum.photos/seed/mixcine_fallback_poster/500/750';
  static const String fallbackBackdropUrl =
      'https://picsum.photos/seed/mixcine_fallback_backdrop/1200/700';
}
