import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:methodchannelpractice/video_player/globals.dart';
import 'package:video_player/video_player.dart';

class CustomControls extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const CustomControls({Key? key, required this.videoPlayerController})
    : super(key: key);

  @override
  State<CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(_videoListener);
    _startAutoHideTimer(); // Start timer initially if autoplaying
  }

  @override
  void dispose() {
    widget.videoPlayerController.removeListener(_videoListener);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls && widget.videoPlayerController.value.isPlaying) {
      _startAutoHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startAutoHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted &&
          widget.videoPlayerController.value.isPlaying &&
          _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    final controller = widget.videoPlayerController;
    if (controller.value.isPlaying) {
      controller.pause();
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      controller.play();
      _startAutoHideTimer();
    }
  }

  String _formatDuration(Duration duration) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final h = duration.inHours;
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.videoPlayerController;

    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          if (controller.value.isBuffering)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          if (_showControls && !controller.value.isBuffering)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final pos = controller.value.position;
                        await controller.seekTo(
                          pos - const Duration(seconds: 10),
                        );
                      },
                      child: const Icon(
                        Icons.replay_10_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: _togglePlayPause,
                      child: Icon(
                        controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 24),
                    InkWell(
                      onTap: () async {
                        final pos = controller.value.position;
                        final dur = controller.value.duration;
                        await controller.seekTo(
                          pos + const Duration(seconds: 10) < dur
                              ? pos + const Duration(seconds: 10)
                              : dur,
                        );
                      },
                      child: const Icon(
                        Icons.forward_10_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_showControls)
            Positioned(
              bottom: 15,
              right: 30,
              child: InkWell(
                onTap: () async {
                  if (isFullscreen) {
                    await SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
                    await SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.pop(context);
                    isFullscreen = false;
                    return;
                  } else if (isFullscreen == false) {
                    isFullscreen = true;
                    final controller = widget.videoPlayerController;

                    await SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);

                    await SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky,
                    );
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          body: SafeArea(
                            child: Stack(
                              children: [
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: VideoPlayer(controller),
                                  ),
                                ),
                                // Reuse your controls here
                                CustomControls(
                                  videoPlayerController: controller,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ),

          // 🕒 Timestamp
          if (_showControls)
            Positioned(
              bottom: 20,
              left: 16,
              child: Text(
                '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // 📊 Progress Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 10,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
