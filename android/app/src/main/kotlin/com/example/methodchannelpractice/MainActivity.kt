package com.example.methodchannelpractice

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        /// common field used for both
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        /// for home screen method channel
        val homeChannelName = "com.methodchannelpractice/homeChannel"


        val homeChannel = MethodChannel(messenger,homeChannelName)

         homeChannel.setMethodCallHandler{
             call,result ->
             HomeChannel.handle(call,result,this,homeChannel)
        }



       /// for landing screen method channel
        val landingChannelName = "com.methodchannelpractice/landingChannel"
        val landingChannel = MethodChannel(messenger,landingChannelName)

        landingChannel.setMethodCallHandler{
                call,result ->
            LandingChannel.handle(call,result,this,landingChannel)
        }

    }
}
