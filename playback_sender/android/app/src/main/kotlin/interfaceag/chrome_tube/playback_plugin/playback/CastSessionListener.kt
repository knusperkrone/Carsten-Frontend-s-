package interfaceag.chrome_tube.playback_plugin.playback

import android.util.Log
import androidx.mediarouter.media.MediaRouter
import com.google.android.gms.cast.CastDevice
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.CastState
import com.google.android.gms.cast.framework.CastStateListener
import com.google.android.gms.cast.framework.SessionManagerListener

internal class CastSessionManagerListener(private val castSessionListener: CastPlaybackContext) : SessionManagerListener<CastSession>, CastStateListener {

    override fun onSessionEnding(castSession: CastSession) {}
    override fun onSessionSuspended(castSession: CastSession, p1: Int) {}

    override fun onSessionStarting(castSession: CastSession) =
            castSessionListener.onChromecastConnecting()


    override fun onSessionResuming(castSession: CastSession, p1: String) =
            castSessionListener.onChromecastConnecting()


    override fun onSessionEnded(castSession: CastSession, error: Int) =
            castSessionListener.onChromecastDisconnected(castSession)


    override fun onSessionResumed(castSession: CastSession, wasSuspended: Boolean) =
            castSessionListener.onChromecastConnected(castSession)


    override fun onSessionResumeFailed(castSession: CastSession, p1: Int) =
            castSessionListener.onChromecastFailed()


    override fun onSessionStarted(castSession: CastSession, sessionId: String) {
        castSessionListener.onChromecastConnected(castSession)
    }

    override fun onSessionStartFailed(castSession: CastSession, p1: Int) =
            castSessionListener.onChromecastFailed()

    override fun onCastStateChanged(state: Int) {
        if (state == CastState.NOT_CONNECTED && castSessionListener.isChromecastConnected) {
            castSessionListener.onChromecastFailed()
        }
    }
}
