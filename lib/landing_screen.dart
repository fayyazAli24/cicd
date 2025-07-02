import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:methodchannelpractice/home_screen.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

  final channel = MethodChannel("com.methodchannelpractice/landingChannel");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Landing Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: _callLandingNativeMethod,
          child: Text('Call'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
      ),
    );
  }

  Future<void> _callLandingNativeMethod() async {
    try {
      final response = await channel.invokeMethod('landingNative');
      print('message recieved successfully $response');
    } catch (e) {
      print('error while recieving message $e');
    }
  }
}
