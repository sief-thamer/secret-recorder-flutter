package com.secretrecorder.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.secretrecorder.R
import java.io.*
import java.text.SimpleDateFormat
import java.util.*

class RecordingService : Service() {

    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var recordingThread: Thread? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startRecording()
            ACTION_STOP -> stopRecording()
        }
        return START_STICKY
    }

    private fun startRecording() {
        if (isRecording) return

        try {
            createNotificationChannel()
            val notification = createNotification()
            startForeground(NOTIFICATION_ID, notification)

            val sampleRate = 44100
            val channelConfig = AudioFormat.CHANNEL_IN_MONO
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT
            val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize
            )

            val fileName = "AUDIO_${SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())}.pcm"
            val file = File(filesDir, "recordings/$fileName")
            file.parentFile?.mkdirs()

            audioRecord?.startRecording()
            isRecording = true

            recordingThread = Thread {
                try {
                    val outputStream = BufferedOutputStream(FileOutputStream(file))
                    val buffer = ByteArray(bufferSize)

                    while (isRecording) {
                        val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                        if (read > 0) {
                            outputStream.write(buffer, 0, read)
                        }
                    }

                    outputStream.flush()
                    outputStream.close()

                    // Notify Flutter
                    val resultIntent = Intent("com.secretrecorder.RECORDING_SAVED")
                    resultIntent.putExtra("file_path", file.absolutePath)
                    resultIntent.putExtra("file_name", fileName)
                    sendBroadcast(resultIntent)

                } catch (e: Exception) {
                    Log.e("RecordingService", "Recording error", e)
                }
            }
            recordingThread?.start()

        } catch (e: SecurityException) {
            Log.e("RecordingService", "No audio permission", e)
        }
    }

    private fun stopRecording() {
        isRecording = false
        recordingThread?.join(1000)
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        stopForeground(true)
        stopSelf()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Recording",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val stopIntent = Intent(this, RecordingService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Secret Recorder")
            .setContentText("Recording audio...")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .setSilent(true)
            .addAction(android.R.drawable.ic_media_pause, "Stop", stopPendingIntent)
            .build()
    }

    companion object {
        const val CHANNEL_ID = "recording_channel"
        const val NOTIFICATION_ID = 1337
        const val ACTION_START = "com.secretrecorder.START_RECORDING"
        const val ACTION_STOP = "com.secretrecorder.STOP_RECORDING"

        fun start(context: Context) {
            val intent = Intent(context, RecordingService::class.java).apply {
                action = ACTION_START
            }
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, RecordingService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }
}
