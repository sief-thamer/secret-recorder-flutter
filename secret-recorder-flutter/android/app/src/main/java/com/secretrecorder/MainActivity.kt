package com.secretrecorder

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.secretrecorder/native"
    private var methodChannel: MethodChannel? = null

    private val dialCodeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val code = intent?.getStringExtra("code") ?: return
            methodChannel?.invokeMethod("onDialCode", mapOf("code" to code))
        }
    }

    private val outgoingCallReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val number = intent?.getStringExtra("number") ?: return
            methodChannel?.invokeMethod("onOutgoingCall", mapOf("number" to number))
        }
    }

    private val recordingSavedReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val filePath = intent?.getStringExtra("file_path") ?: return
            val fileName = intent?.getStringExtra("file_name") ?: return
            methodChannel?.invokeMethod("onRecordingSaved", mapOf(
                "filePath" to filePath,
                "fileName" to fileName
            ))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    RecordingService.start(this)
                    result.success(true)
                }
                "stopRecording" -> {
                    RecordingService.stop(this)
                    result.success(true)
                }
                "getFilesDir" -> {
                    result.success(filesDir.absolutePath)
                }
                else -> result.notImplemented()
            }
        }

        // Register receivers
        val dialFilter = IntentFilter("com.secretrecorder.DIAL_CODE_RECEIVED")
        val callFilter = IntentFilter("com.secretrecorder.OUTGOING_CALL")
        val recordingFilter = IntentFilter("com.secretrecorder.RECORDING_SAVED")

        registerReceiver(dialCodeReceiver, dialFilter)
        registerReceiver(outgoingCallReceiver, callFilter)
        registerReceiver(recordingSavedReceiver, recordingFilter)
    }

    override fun onDestroy() {
        unregisterReceiver(dialCodeReceiver)
        unregisterReceiver(outgoingCallReceiver)
        unregisterReceiver(recordingSavedReceiver)
        super.onDestroy()
    }
}
