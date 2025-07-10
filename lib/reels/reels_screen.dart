import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../video_player/custom_video_controller.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController pageController;
  double _aspectRatio = 16 / 9;
  List thumbnails = [];

  List<String> urls = [
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
  ];

  int videoIndex = 0;

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isVideoLoading = true;
  bool isThumbnailLoading = true;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _generateAllThumbnails();
    _initializePlayer(videoIndex);
  }

  Future<void> _generateAllThumbnails() async {
    setState(() {
      isThumbnailLoading = true;
      thumbnails.clear();
    });

    for (int i = 0; i < urls.length; i++) {
      try {
        final thumb = await VideoThumbnail.thumbnailData(
          video: urls[i],
          imageFormat: ImageFormat.PNG,
          maxWidth: 400, // Safer value
          quality: 75,
        );

        if (thumb != null) {
          thumbnails.add(thumb);
        } else {
          print('Failed to generate thumbnail for: ${urls[i]}');
          thumbnails.add(null); // Add null to maintain index alignment
        }
      } catch (e) {
        print('Error generating thumbnail for ${urls[i]}: $e');
        thumbnails.add(null);
      }
    }

    setState(() {
      isThumbnailLoading = false;
    });
  }

  Future<void> _initializePlayer(int index) async {
    setState(() => isVideoLoading = true);
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(urls[index]),
    );
    await _videoPlayerController.initialize();

    _aspectRatio = _videoPlayerController.value.aspectRatio;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
      customControls: CustomControls(
        videoPlayerController: _videoPlayerController,
      ),
    );
    setState(() => isVideoLoading = false);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isThumbnailLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              itemCount: urls.length,
              controller: pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) async {
                videoIndex = index;
                await _videoPlayerController.dispose();
                _chewieController!.dispose();
                _initializePlayer(index);
              },
              itemBuilder: (context, index) {
                return Center(
                  child: isVideoLoading || _chewieController == null
                      ? AspectRatio(
                          aspectRatio: _aspectRatio,
                          child: Stack(
                            children: [
                              Image.memory(thumbnails[index]),
                              Positioned.fill(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: _aspectRatio,
                          child: Chewie(controller: _chewieController!),
                        ),
                );
              },
            ),
    );
  }
}
