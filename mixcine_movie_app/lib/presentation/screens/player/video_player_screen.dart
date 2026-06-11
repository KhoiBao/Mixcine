import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:mixcine_movie_app/presentation/providers/subscription_provider.dart';
import 'package:mixcine_movie_app/domain/entities/payment_plan.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/movie_detail_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({required this.movieId, super.key});

  final int movieId;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  String? _errorMessage;
  bool _isInitializing = true;
  String _title = 'Player';
  
  // LOGIC QUẢNG CÁO
  bool _isShowingAd = false;
  int _adCountdown = 5;
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_checkAdsAndSetup);
  }

  Future<void> _checkAdsAndSetup() async {
    // 1. Kiểm tra gói cước từ subscriptionProvider
    final subscription = ref.read(subscriptionProvider);
    final plan = subscription?.plan ?? PaymentPlan.free;

    if (plan.hasAds) {
      // Nếu có quảng cáo (Gói FREE)
      setState(() {
        _isShowingAd = true;
        _isInitializing = false;
      });
      _startAdTimer();
    } else {
      // Nếu là VIP/VIP PRO -> Vào phim luôn
      _setupVideo();
    }
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_adCountdown > 1) {
        setState(() => _adCountdown--);
      } else {
        _adTimer?.cancel();
        setState(() {
          _isShowingAd = false;
          _isInitializing = true; // Bắt đầu hiện loading để load phim
        });
        _setupVideo();
      }
    });
  }

  Future<void> _setupVideo() async {
    try {
      final movie = await ref.read(movieDetailProvider(widget.movieId).future);
      final controller = VideoPlayerController.networkUrl(Uri.parse(movie.videoUrl));
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _title = movie.title;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải video, vui lòng thử lại sau.';
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // 1. GIAO DIỆN QUẢNG CÁO MIXI88
    if (_isShowingAd) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.red.withOpacity(0.3), Colors.black],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino_rounded, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'MIXI88',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 64,
                  fontWeight: FontWeight.w900, // Sửa FontWeight.black thành w900
                  letterSpacing: 8,
                  shadows: [
                    Shadow(color: Colors.white, blurRadius: 10),
                  ],
                ),
              ),
              const Text(
                'NHÀ CÁI ĐẾN TỪ CHÂU ÂU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 60),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _adCountdown / 5,
                      color: Colors.redAccent,
                      strokeWidth: 6,
                    ),
                  ),
                  Text(
                    '$_adCountdown',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Quảng cáo sẽ kết thúc sau vài giây...',
                style: TextStyle(color: Colors.white60),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.amber), // Sửa Icon mới
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nâng cấp VIP ngay để tắt quảng cáo vĩnh viễn!',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.amber.withOpacity(0.7)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. GIAO DIỆN PLAYER CHÍNH
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.black,
      ),
      body: Builder(
        builder: (context) {
          if (_isInitializing) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (_errorMessage != null || _controller == null) {
            return Center(
              child: Text(
                _errorMessage ?? 'Lỗi không xác định',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final controller = _controller!;

          return Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final value = controller.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: AppColors.primary,
                            backgroundColor: Colors.white24,
                            bufferedColor: Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            IconButton.filled(
                              onPressed: () async {
                                if (value.isPlaying) {
                                  await controller.pause();
                                } else {
                                  await controller.play();
                                }
                                setState(() {});
                              },
                              icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow_rounded),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await controller.seekTo(Duration.zero);
                                await controller.play();
                              },
                              icon: const Icon(Icons.replay_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
