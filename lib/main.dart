import 'package:flutter/material.dart';
import 'package:methodchannelpractice/home_screen.dart';
import 'package:methodchannelpractice/reels/reels_screen.dart';
import 'package:methodchannelpractice/video_player/video_player_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',

      /// reels screen
      home: ReelsScreen(),

      /// video player screen
      // home: MyVideoPlayerScreenWithResume(
      //   videoUrl:
      //       'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      //   videoId: '1',
      // ),
    );
  }
}
