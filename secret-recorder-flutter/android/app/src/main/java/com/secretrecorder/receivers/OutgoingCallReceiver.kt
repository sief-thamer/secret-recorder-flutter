package com.secretrecorder.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log

class OutgoingCallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_NEW_OUTGOING_CALL) return

        val phoneNumber = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER) ?: return
        val cleanNumber = phoneNumber.replace("[^0-9*#]".toRegex(), "")

        Log.d("SecretDial", "Outgoing call to: $cleanNumber")

        // Send to Flutter
        val broadcastIntent = Intent("com.secretrecorder.OUTGOING_CALL")
        broadcastIntent.putExtra("number", cleanNumber)
        context.sendBroadcast(broadcastIntent)
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
