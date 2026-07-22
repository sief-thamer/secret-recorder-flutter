package com.secretrecorder.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log

class SecretDialReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val data = intent.data ?: return
        val code = data.schemeSpecificPart ?: return

        Log.d("SecretDial", "Dial code received: $code")

        // Send to Flutter via MethodChannel
        val intent2 = Intent("com.secretrecorder.DIAL_CODE_RECEIVED")
        intent2.putExtra("code", code)
        context.sendBroadcast(intent2)

        // Vibrate
        vibrateShort(context)
    }

    private fun vibrateShort(context: Context) {
        val vibrator = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        vibrator.vibrate(VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE))
    }
}
