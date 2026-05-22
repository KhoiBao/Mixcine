import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

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

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_setupVideo);
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
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unable to load the sample video.';
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.black,
      ),
      body: Builder(
        builder: (context) {
          if (_isInitializing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_errorMessage != null || _controller == null) {
            return Center(
              child: Text(
                _errorMessage ?? 'Unknown playback error',
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
                        const SizedBox(height: 8),
                        const Text(
                          'This screen uses video_player with a sample online mp4 so the flow stays simple and easy to extend.',
                          style: TextStyle(color: Colors.white70),
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
