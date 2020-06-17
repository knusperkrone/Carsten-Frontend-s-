package interfaceag.chrome_tube.playback_plugin.playback

import android.util.Log
import com.google.android.gms.cast.Cast
import com.google.android.gms.cast.CastDevice
import com.google.android.gms.cast.framework.SessionManager

interface CastMessageCallback {
    fun onReceive(msg: String)
}

internal class CastPlaybackChannel(private val sessionManager: SessionManager, private val mCallback: CastMessageCallback) : Cast.MessageReceivedCallback {
    companion object {
        private const val TAG = "CastPlaybackChannel"
        const val NAMESPACE = "urn:x-cast:com.pierfrancescosoffritti.androidyoutubeplayer.chromecast.communication"
    }

    fun sendMessage(message: String) {
        try {
            // Log.d(TAG, "Send: $message")
            sessionManager.currentCastSession.sendMessage(NAMESPACE, message)
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }
    }

    override fun onMessageReceived(castDevice: CastDevice, namespace: String, parsedMessage: String) {
        // Log.d(TAG, "Received: $parsedMessage")
        mCallback.onReceive(parsedMessage)
    }

}