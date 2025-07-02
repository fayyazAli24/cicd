import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:methodchannelpractice/landing_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  var channel = MethodChannel("com.methodchannelpractice/homeChannel");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: _callNativeMethod,
          child: Text('Call'),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LandingScreen()),
        );

      }),
    );
  }

  Future<void> _callNativeMethod() async {
    try {
      final response = await channel.invokeMethod('homeNative');
      print('message recieved successfully $response');
    } catch (e) {
      print('error while recieving message $e');
    }
  }
}
