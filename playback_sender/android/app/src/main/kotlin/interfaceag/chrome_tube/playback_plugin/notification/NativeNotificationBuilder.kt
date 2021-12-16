package interfaceag.chrome_tube.playback_plugin.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Base64
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.palette.graphics.Palette
import interfaceag.chrome_tube.MainActivity
import interfaceag.chrome_tube.R
import interfaceag.chrome_tube.playback_plugin.NativeConstants
import interfaceag.chrome_tube.playback_plugin.notification.PlaybackNotificationReceiver.Companion.NEXT_INTENT_NAME
import interfaceag.chrome_tube.playback_plugin.notification.PlaybackNotificationReceiver.Companion.NOP_INTENT_NAME
import interfaceag.chrome_tube.playback_plugin.notification.PlaybackNotificationReceiver.Companion.PLAY_INTENT_NAME
import interfaceag.chrome_tube.playback_plugin.notification.PlaybackNotificationReceiver.Companion.PREVIOUS_INTENT_NAME
import interfaceag.chrome_tube.playback_plugin.notification.PlaybackNotificationReceiver.Companion.STOP_INTENT_NAME
import interfaceag.chrome_tube.playback_plugin.service.CastConnectionService
import org.json.JSONObject


private data class TrackIndicatorMessage(val title: String, val artist: String,
                                         val playlistName: String, val coverB64: String?,
                                         val isBuffering: Boolean, val isPlaying: Boolean)


class NativeNotificationBuilder(private val mContext: Context, private val mService: CastConnectionService) {
    companion object {
        internal const val NOTIFICATION_ID = 0x80

        private const val TAG = "NativeNotificationBuild"
        private const val CHANNEL_ID = "MediaControl_ID_Channel"
        private const val CHANNEL_NAME = "MediaControl" // TODO: Local res
        private const val CHANNEL_DESCR = "Control the app" // TODO: Local res

        // Broadcast intent
        private val PLAY_INTENT = Intent(PLAY_INTENT_NAME)
        private val NEXT_INTENT = Intent(NEXT_INTENT_NAME)
        private val PREV_INTENT = Intent(PREVIOUS_INTENT_NAME)
        private val STOP_INTENT = Intent(STOP_INTENT_NAME)
        private val NOP_INTENT = Intent(NOP_INTENT_NAME)
    }


    private val mNotiManager = NotificationManagerCompat.from(mContext)

    init {
        setupIntents()
        setupNotificationChannel()
    }

    @RequiresApi(Build.VERSION_CODES.FROYO)
    fun build(parsedMsg: JSONObject) {
        // Proguard workaround
        val noti: Notification?
        val data = parsedMsg["data"] as String

        when (parsedMsg["type"]) {
            NativeConstants.N_MSG_INFO -> noti = buildUserNotification(data)
            NativeConstants.N_MSG_TRACK -> {
                val dataObj = JSONObject(data)
                val msg = TrackIndicatorMessage(
                        dataObj.getString("title"),
                        dataObj.getString("artist"),
                        dataObj.getString("playlistName"),
                        dataObj.getString("coverB64"),
                        dataObj.getBoolean("isBuffering"),
                        dataObj.getBoolean("isPlaying")
                )
                noti = buildTrackNoti(msg)
            }
            else -> {
                Log.e(TAG, "Invalid message:\n$parsedMsg")
                noti = null
            }
        }
        if (noti != null) {
            mNotiManager.notify(NOTIFICATION_ID, noti)
        }
    }

    fun buildUserNotification(text: String): Notification {
        return NotificationCompat.Builder(mContext, CHANNEL_ID)
                .setContentText(text)
                .setSmallIcon(R.drawable.ic_cast)
                .setOngoing(true)
                .build()
    }

    fun clear() {
        mNotiManager.cancel(NOTIFICATION_ID)
    }

    @RequiresApi(Build.VERSION_CODES.FROYO)
    private fun buildTrackNoti(trackMsg: TrackIndicatorMessage): Notification {
        val builder = NotificationCompat.Builder(mContext, CHANNEL_ID)
        builder.setSubText(trackMsg.playlistName)
        builder.setContentText(trackMsg.artist)
        builder.setContentTitle(trackMsg.title)
        builder.setSmallIcon(R.drawable.ic_cast_connected)
        builder.setOngoing(true)

        // Intent stuff
        val intentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val contentIntent = Intent(mContext, MainActivity::class.java)
        contentIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        val resultContentIntent = PendingIntent.getActivity(mContext, 0, contentIntent, intentFlags)

        val pendingPlayIntent = PendingIntent.getBroadcast(mContext, PlaybackNotificationReceiver.INTENT_REQUEST_CODE, PLAY_INTENT, intentFlags)
        val pendingNextIntent = PendingIntent.getBroadcast(mContext, PlaybackNotificationReceiver.INTENT_REQUEST_CODE, NEXT_INTENT, intentFlags)
        val pendingStopIntent = PendingIntent.getBroadcast(mContext, PlaybackNotificationReceiver.INTENT_REQUEST_CODE, STOP_INTENT, intentFlags)
        val pendingPrevIntent = PendingIntent.getBroadcast(mContext, PlaybackNotificationReceiver.INTENT_REQUEST_CODE, PREV_INTENT, intentFlags)
        val pendingNopIntent = PendingIntent.getBroadcast(mContext, PlaybackNotificationReceiver.INTENT_REQUEST_CODE, NOP_INTENT, intentFlags)

        var pendingActionIntent = pendingPlayIntent
        var drawable = R.drawable.ic_play
        if (trackMsg.isBuffering) {
            drawable = R.drawable.spin_anim
            pendingActionIntent = pendingNopIntent
        } else if (trackMsg.isPlaying) {
            drawable = R.drawable.ic_pause
        }

        builder.setContentIntent(resultContentIntent)
        builder.addAction(R.drawable.ic_previous, PREVIOUS_INTENT_NAME, pendingPrevIntent) // 0
        builder.addAction(drawable, PLAY_INTENT_NAME, pendingActionIntent) // 1
        builder.addAction(R.drawable.ic_stop, STOP_INTENT_NAME, pendingStopIntent) // 2
        builder.addAction(R.drawable.ic_next, NEXT_INTENT_NAME, pendingNextIntent) // 3
        builder.setStyle(androidx.media.app.NotificationCompat.MediaStyle()
                .setShowActionsInCompactView(0, 1, 3))

        // Depreciated, but way easier.
        if (trackMsg.coverB64 != null) {
            val decodedString = Base64.decode(trackMsg.coverB64, Base64.DEFAULT)
            val resource = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)

            val palette = Palette.Builder(resource).generate()
            builder.setLargeIcon(resource)
            builder.color = palette.getDominantColor(0x0)
            builder.setColorized(true)
        }

        return builder.build()
    }

    private fun setupIntents() {
        val receiver = PlaybackNotificationReceiver(mService)
        val intentFilter = IntentFilter()

        intentFilter.addCategory(Intent.CATEGORY_DEFAULT)
        intentFilter.addAction(PLAY_INTENT_NAME)
        intentFilter.addAction(NEXT_INTENT_NAME)
        intentFilter.addAction(PREVIOUS_INTENT_NAME)
        intentFilter.addAction(STOP_INTENT_NAME)
        intentFilter.addAction(NOP_INTENT_NAME)
        mContext.registerReceiver(receiver, intentFilter)
    }

    private fun setupNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = CHANNEL_NAME
            val description = CHANNEL_DESCR
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance)
            channel.description = description
            channel.setSound(null, null)
            channel.enableLights(false)
            channel.enableVibration(false)

            val notificationManager = mContext.getSystemService(NotificationManager::class.java)
            notificationManager!!.createNotificationChannel(channel)
        }
    }

}