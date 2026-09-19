import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Professional video player with playback controls, speed, and fullscreen
class EnhancedVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool autoPlay;

  const EnhancedVideoPlayer({
    super.key,
    required this.controller,
    this.autoPlay = true,
  });

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    if (widget.autoPlay) {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top controls
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Text('VIDEO DARS',
                            style: AppTextStyles.label
                                .copyWith(color: Colors.white70)),
                        IconButton(
                          icon: const Icon(Icons.fullscreen,
                              color: Colors.white, size: 24),
                          onPressed: _enterFullscreen,
                        ),
                      ],
                    ),
                  ),
                  // Center play/pause
                  if (!_controller.value.isPlaying)
                    InkWell(
                      onTap: () => _controller.play(),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            size: 36, color: Color(0xFF3D2E52)),
                      ),
                    ),
                  // Bottom controls
                  Container(
                    color: Colors.black45,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress bar
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: AppColors.pink,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Time and controls
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                _formatDuration(
                                    _controller.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            PopupMenuButton<double>(
                              onSelected: (speed) {
                                _controller.setPlaybackSpeed(speed);
                                setState(() => _playbackSpeed = speed);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Speed: ${speed}x'),
                                    duration: const Duration(
                                        milliseconds: 800),
                                  ),
                                );
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 0.5,
                                  child: Text('0.5x'),
                                ),
                                const PopupMenuItem(
                                  value: 1.0,
                                  child: Text('1.0x (Normal)'),
                                ),
                                const PopupMenuItem(
                                  value: 1.5,
                                  child: Text('1.5x'),
                                ),
                                const PopupMenuItem(
                                  value: 2.0,
                                  child: Text('2.0x'),
                                ),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(
                                  _controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _enterFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
