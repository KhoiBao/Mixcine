import 'dart:math';

import '../../core/config/app_config.dart';
import '../models/movie_model.dart';

class MockMovieDataSource {
  final List<MovieModel> _movies = const <MovieModel>[
    MovieModel(
      id: 1,
      title: 'Dune Legacy',
      overview: 'A desert world, noble houses, and a prophecy that changes the balance of power.',
      posterUrl: 'https://picsum.photos/seed/movie_1/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_1/1200/700',
      rating: 8.7,
      releaseDate: '2024-02-16',
      genres: ['Khoa học - viễn tưởng', 'Phiêu lưu'],
      durationMinutes: 155,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3654144259/preview/stock-footage-cat-meme-banana-dress-banana-and-cat-costume-green-screen-background.mp4', // Đổi từ link .png sang link demo
      requiredTier: 3, // Phim Vippro
    ),
    MovieModel(
      id: 2,
      title: 'Midnight Hacker',
      overview: 'A student hacker discovers a surveillance tool hidden inside a streaming platform.',
      posterUrl: 'https://picsum.photos/seed/movie_2/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_2/1200/700',
      rating: 7.9,
      releaseDate: '2025-01-12',
      genres: ['Gay cấn', 'Tội phạm'],
      durationMinutes: 121,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3733689975/preview/stock-footage-cat-confused-by-computer-pixel-art-animation-meme.mp4', // Đổi sang link demo
      requiredTier: 2, // Phim VIP
    ),
    MovieModel(
      id: 3,
      title: 'Skyline 2049',
      overview: 'A futuristic detective follows clues across a neon megacity after a mysterious blackout.',
      posterUrl: 'https://picsum.photos/seed/movie_3/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_3/1200/700',
      rating: 8.4,
      releaseDate: '2023-10-03',
      genres: ['Khoa học - viễn tưởng', 'Huyền bí'],
      durationMinutes: 138,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3951217585/preview/stock-footage-a-cat-with-rosy-cheeks-and-a-heart-shaped-hand-gesture-this-is-a-funny-picture-cat-meme-animation.mp4',
      requiredTier: 1, // Phim Thường
    ),
    MovieModel(
      id: 4,
      title: 'Runway to Tokyo',
      overview: 'A fashion intern lands in Tokyo and learns that ambition always comes with a price.',
      posterUrl: 'https://picsum.photos/seed/movie_4/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_4/1200/700',
      rating: 7.3,
      releaseDate: '2025-08-19',
      genres: ['Drama', 'Lãng mạn'],
      durationMinutes: 110,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3990076433/preview/stock-footage-cat-meme-the-loading-cat-or-buffering-cat-meme-it-s-often-used-to-express-confusion.mp4',
      requiredTier: 1, // Phim Thường
    ),
    MovieModel(
      id: 5,
      title: 'The Last Orbit',
      overview: 'A rescue mission near Saturn turns into a survival story between trust and sacrifice.',
      posterUrl: 'https://picsum.photos/seed/movie_5/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_5/1200/700',
      rating: 8.9,
      releaseDate: '2024-11-02',
      genres: ['Khoa học - viễn tưởng', 'Drama'],
      durationMinutes: 147,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3990305869/preview/stock-footage-meme-cat-funny-cat-laughing-meme-green-screen.mp4',
      requiredTier: 3, // Phim Vippro
    ),
    MovieModel(
      id: 6,
      title: 'Paper Crown',
      overview: 'The youngest candidate in a royal election shakes a kingdom built on old secrets.',
      posterUrl: 'https://picsum.photos/seed/movie_6/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_6/1200/700',
      rating: 7.6,
      releaseDate: '2023-07-17',
      genres: ['Drama', 'Lịch sử'],
      durationMinutes: 132,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3990305869/preview/stock-footage-meme-cat-funny-cat-laughing-meme-green-screen.mp4',
      requiredTier: 2, // Phim VIP
    ),
    MovieModel(
      id: 7,
      title: 'After Rainfall',
      overview: 'Two strangers reconnect every monsoon season and rewrite the story of their hometown.',
      posterUrl: 'https://picsum.photos/seed/movie_7/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_7/1200/700',
      rating: 7.8,
      releaseDate: '2022-04-27',
      genres: ['Lãng mạn', 'Drama'],
      durationMinutes: 104,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3918644833/preview/stock-footage-cartoon-cat-calmly-holding-coffee-while-watching-laptop-on-fire-loop-animation-alpha-channel.mp4',
      requiredTier: 1, // Phim Thường
    ),
    MovieModel(
      id: 8,
      title: 'Monster Street',
      overview: 'A comic artist accidentally sketches creatures that begin to appear in real life.',
      posterUrl: 'https://picsum.photos/seed/movie_8/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_8/1200/700',
      rating: 7.1,
      releaseDate: '2025-06-10',
      genres: ['Hài', 'Giả tưởng'],
      durationMinutes: 99,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3432394165/preview/stock-footage-cat-in-fire-meme-this-is-fine-text-bubble-video-animation-hand-drawn-in-a-cartoon-style-high.mp4',
      requiredTier: 1, // Phim Thường
    ),
    MovieModel(
      id: 9,
      title: 'Shadow Protocol',
      overview: 'An undercover agent races across Europe after a covert operation collapses overnight.',
      posterUrl: 'https://picsum.photos/seed/movie_9/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_9/1200/700',
      rating: 8.2,
      releaseDate: '2024-09-05',
      genres: ['Hành động', 'Gay cấn'],
      durationMinutes: 128,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3724014321/preview/stock-footage-math-and-physics-formula-animation-with-handwriting-style-animated-mathematical-formula-is.mp4',
      requiredTier: 2, // Phim VIP
    ),
    MovieModel(
      id: 10,
      title: 'Quiet Letters',
      overview: 'A retiring postman starts reading the stories hidden between undelivered letters.',
      posterUrl: 'https://picsum.photos/seed/movie_10/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_10/1200/700',
      rating: 8.0,
      releaseDate: '2023-12-22',
      genres: ['Drama', 'Gia đình'],
      durationMinutes: 113,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/1105455297/preview/stock-footage-a-man-gives-the-mind-blown-meme-gesture-space-background.mp4',
      requiredTier: 1, // Phim Thường
    ),
    MovieModel(
      id: 11,
      title: 'Zero Gravity Club',
      overview: 'A group of trainees on a damaged orbital station must finish their final exam for real.',
      posterUrl: 'https://picsum.photos/seed/movie_11/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_11/1200/700',
      rating: 8.5,
      releaseDate: '2025-03-01',
      genres: ['Phiêu lưu', 'Khoa học - viễn tưởng'],
      durationMinutes: 143,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/1095400467/preview/stock-footage-man-raising-hands-asking-what-why-reason-of-failure-demonstrating-disbelief-irritation-by-troubles.mp4',
      requiredTier: 3, // Phim Vippro
    ),
    MovieModel(
      id: 12,
      title: 'Burning Signals',
      overview: 'A late-night radio host receives calls that predict disasters before they happen.',
      posterUrl: 'https://picsum.photos/seed/movie_12/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_12/1200/700',
      rating: 7.7,
      releaseDate: '2024-05-25',
      genres: ['Huyền bí', 'GAY cấn'],
      durationMinutes: 118,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3602950807/preview/stock-footage-surprised-cat-pixel-art-animation-meme.mp4',
      requiredTier: 2, // Phim VIP
    ),
    MovieModel(
      id: 13,
      title: 'Naruto',
      overview: 'A late-night radio host receives calls that predict disasters before they happen.',
      posterUrl: 'https://m.media-amazon.com/images/I/81Zj-BWityL._AC_UF894,1000_QL80_.jpg',
      backdropUrl: 'https://i.pinimg.com/736x/30/83/f9/3083f9040144964313d24235c8d4debe.jpg',
      rating: 8.5,
      releaseDate: '2024-05-25',
      genres: ['Hoạt hình'],
      durationMinutes: 120,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3584342685/preview/stock-footage-sidoarjo-indonesia-august-a-person-is-reading-a-naruto-manga-or-comic-the-photo-from.mp4',
      requiredTier: 1, // Phim thường
    ),
    MovieModel(
      id: 14,
      title: 'Dragon Balls',
      overview: 'A late-night radio host receives calls that predict disasters before they happen.',
      posterUrl: 'https://i.ebayimg.com/images/g/jR0AAOSw6WFm7P~y/s-l400.jpg',
      backdropUrl: 'https://cdn.europosters.eu/image/1300/88632.jpg',
      rating: 9.0,
      releaseDate: '2017-10-08',
      genres: ['Hoạt hình'],
      durationMinutes: 120,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/1098892981/preview/stock-footage-december-goku-a-fictional-character-of-dragon-ball-becomes-a-super-saiyan-for-the-first.mp4',
      requiredTier: 1, // Phim thường
    ),
    MovieModel(
      id: 15,
      title: 'Mưa đỏ',
      overview: 'Lấy cảm hứng từ sự kiện 81 ngày đêm chiến đấu tại Thành cổ Quảng Trị năm 1972, bộ phim là khúc tráng ca tri ân những người lính trẻ đã dâng hiến tuổi thanh xuân cho đất nước, khắc họa tình đồng đội và khát vọng hòa bình.',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/vi/4/49/Mua_do_poster.jpg',
      backdropUrl: 'https://vov2.vov.vn/sites/default/files/styles/large/public/2025-08/mua-do-2.jpg',
      rating: 9.9,
      releaseDate: '2025-08-22',
      genres: ['Lịch sử', 'Chiến tranh'],
      durationMinutes: 124,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3602950807/preview/stock-footage-surprised-cat-pixel-art-animation-meme.mp4',
      requiredTier: 1, // Phim thường
    ),
    MovieModel(
      id: 16,
      title: 'Meltdown: Three Mile Island',
      overview: 'Three Mile Island tái hiện sự cố hạt nhân nghiêm trọng nhất trong lịch sử Hoa Kỳ tại nhà máy điện Three Mile Island. Bộ phim phác họa những quyết định quan trọng, diễn biến phức tạp và hậu quả lâu dài.',
      posterUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtjypE62gPrWkRY6ctlMPtF4bUKcSuN1r1Og&s',
      backdropUrl: 'https://m.media-amazon.com/images/M/MV5BMDYzZWI1YzItMGRmMy00NWExLTg1Y2UtNTFmMDg4NWI2ZDRmXkEyXkFqcGdeQVRoaXJkUGFydHlJbmdlc3Rpb25Xb3JrZmxvdw@@._V1_QL75_UX500_CR0,0,500,281_.jpg',
      rating: 7.0,
      releaseDate: '2022-11-10',
      genres: ['Tài liệu', 'Khoa học'],
      durationMinutes: 95,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3602950807/preview/stock-footage-surprised-cat-pixel-art-animation-meme.mp4',
      requiredTier: 1, // Phim Thường
    ),
    MovieModel(
      id: 17,
      title: 'IT - Gã hề ma quái',
      overview: 'Chú hề ma quái là một bộ phim kinh dị siêu nhiên Mỹ ra mắt năm 2017 của đạo diễn Andy Muschietti. Đây là phần đầu tiên trong kế hoạch sản xuất loạt phim It hai phần dựa trên cuốn tiểu thuyết cùng tên của nhà văn Stephen King.',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/vi/thumb/7/7a/It-chuhemaquai-apphich.jpeg/250px-It-chuhemaquai-apphich.jpeg',
      backdropUrl: 'https://cdn-images.vtv.vn/2017/photo-1-1506761077455.jpg',
      rating: 7.4,
      releaseDate: '2017-10-31',
      genres: ['Kinh dị', 'GAY cấn'],
      durationMinutes: 105,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/3602950807/preview/stock-footage-surprised-cat-pixel-art-animation-meme.mp4',
      requiredTier: 1, // Phim thường
    ),
    MovieModel(
      id: 18,
      title: 'Đàn cá gỗ',
      overview: 'Đàn cá gỗ là một bộ phim ngắn điện ảnh độc lập Việt Nam thuộc thể loại lãng mạn – chính kịch ra mắt năm 2025, do Nguyễn Phạm Thành Đạt làm đạo diễn, biên kịch kiêm nhà sản xuất.',
      posterUrl: 'https://upload.wikimedia.org/wikipedia/vi/b/b6/Dan_ca_go_poster.jpg',
      backdropUrl: 'https://i.ytimg.com/vi/XmfqpFI-bYs/maxresdefault.jpg',
      rating: 8.6,
      releaseDate: '2025-02-08',
      genres: ['Âm nhạc', 'Lãng mạn'],
      durationMinutes: 35,
      videoUrl: 'https://www.shutterstock.com/shutterstock/videos/4035085373/preview/stock-footage-close-up-guitarist-hands-playing-chords-and-solo-on-fretboard-of-black-and-white-electric-guitar.mp4',
      requiredTier: 1, // Phim thường
    ),
  ];

  Future<List<MovieModel>> fetchPopularMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _slicePage(_movies, page);
  }

  Future<List<MovieModel>> fetchTopRatedMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final sorted = [..._movies]..sort((a, b) => b.rating.compareTo(a.rating));
    return _slicePage(sorted, page);
  }

  Future<List<MovieModel>> fetchUpcomingMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final sorted = [..._movies]..sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    return _slicePage(sorted, page);
  }

  Future<List<MovieModel>> fetchDiscoverMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _slicePage(_movies, page);
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return <MovieModel>[];
    }

    return _movies.where((movie) {
      final titleMatch = movie.title.toLowerCase().contains(normalized);
      final genreMatch = movie.genres.any(
            (genre) => genre.toLowerCase().contains(normalized),
      );
      return titleMatch || genreMatch;
    }).toList();
  }

  Future<MovieModel> getMovieDetail(int movieId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _movies.firstWhere((movie) => movie.id == movieId);
  }

  Future<List<MovieModel>> getMoviesByIds(Set<int> ids) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _movies.where((movie) => ids.contains(movie.id)).toList();
  }

  List<MovieModel> _slicePage(List<MovieModel> source, int page) {
    final start = (page - 1) * AppConfig.pageSize;
    if (start >= source.length) {
      return <MovieModel>[];
    }

    final end = min(start + AppConfig.pageSize, source.length);
    return source.sublist(start, end);
  }
}
