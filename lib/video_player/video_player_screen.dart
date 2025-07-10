import 'package:flutter/material.dart';
import 'package:methodchannelpractice/video_player/globals.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_video_controller.dart';

class MyVideoPlayerScreenWithResume extends StatefulWidget {
  final String videoUrl;
  final String videoId;

  const MyVideoPlayerScreenWithResume({
    Key? key,
    required this.videoUrl,
    required this.videoId,
  }) : super(key: key);

  @override
  _MyVideoPlayerScreenWithResumeState createState() =>
      _MyVideoPlayerScreenWithResumeState();
}

class _MyVideoPlayerScreenWithResumeState
    extends State<MyVideoPlayerScreenWithResume> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  SharedPreferences? _prefs;
  bool autoPlay = true;
  double _aspectRatio = 16 / 9;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    autoPlay = true;
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await _videoPlayerController.initialize();
    if (_videoPlayerController.value.isInitialized) {
      _aspectRatio = _videoPlayerController.value.aspectRatio;
    }

    _prefs = await SharedPreferences.getInstance();
    final int? savedPositionMilliseconds = _prefs?.getInt(
      'video_position_${widget.videoId}',
    );

    if (savedPositionMilliseconds != null) {
      autoPlay = false;
      final Duration savedPosition = Duration(
        milliseconds: savedPositionMilliseconds,
      );
      if (savedPosition < _videoPlayerController.value.duration) {
        await _videoPlayerController.seekTo(savedPosition);
      }
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: autoPlay,
      looping: false,
      showControls: true,
      customControls: CustomControls(
        videoPlayerController: _videoPlayerController,
      ),
    );

    _videoPlayerController.addListener(_videoListener);
    setState(() {});
  }

  void _videoListener() {
    if (_videoPlayerController.value.isPlaying ||
        _videoPlayerController.value.position > Duration.zero) {
      _prefs?.setInt(
        'video_position_${widget.videoId}',
        _videoPlayerController.value.position.inMilliseconds,
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? Center(
              child: InkWell(
                onTap: () async {},
                child: AspectRatio(
                  aspectRatio: _aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            )
          : CircularProgressIndicator(),
    );
  }
}
