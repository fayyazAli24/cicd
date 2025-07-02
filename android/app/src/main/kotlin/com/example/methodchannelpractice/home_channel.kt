package com.example.methodchannelpractice

import android.annotation.SuppressLint
import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

@SuppressLint("StaticFieldLeak")
object HomeChannel {
    private  lateinit var  activity: Activity
    private  lateinit var channel: MethodChannel


    fun handle(
        call: MethodCall,
        result: MethodChannel.Result,
        activity: Activity,
        channel: MethodChannel
    ){
        this.activity = activity
        this.channel = channel

        when(call.method){
            "homeNative"->{
                val message = "this is message for the home screen from the native side"
                result.success(message)
            }
        }

    }
}