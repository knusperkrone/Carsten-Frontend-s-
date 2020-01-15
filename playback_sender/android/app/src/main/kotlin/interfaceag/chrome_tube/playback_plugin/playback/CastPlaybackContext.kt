package interfaceag.chrome_tube.playback_plugin.playback

import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManager
import interfaceag.chrome_tube.playback_plugin.io.CastPlaybackChannel
import interfaceag.chrome_tube.playback_plugin.io.EncodedMessageReceivedListener

class CastPlaybackContext(private val castContext: CastContext, listener: EncodedMessageReceivedListener, private val connectionListener: CastPlaybackConnectionListener) {

    private val castSessionManagerListener = CastSessionManagerListener(this)
    private val sessionManager: SessionManager = castContext.sessionManager
    private val castChannel = CastPlaybackChannel(sessionManager, listener)

    var isChromecastConnected = false
        private set

    init {
        castContext.addCastStateListener(castSessionManagerListener)
        sessionManager.addSessionManagerListener(castSessionManagerListener, CastSession::class.java)
    }

    fun dispose() {
        castContext.removeCastStateListener(castSessionManagerListener)
        sessionManager.removeSessionManagerListener(castSessionManagerListener, CastSession::class.java)
    }

    /*
     * Business methods
     */

    fun restoreSession(): Boolean {
        if (sessionManager.currentCastSession != null) {
            castSessionManagerListener.onSessionResumed(sessionManager.currentCastSession, false)
        }
        return true
    }

    fun endCurrentSession(): Boolean {
        sessionManager.endCurrentSession(true)
        return true
    }

    fun sendMessage(msg: String): Boolean {
        if (!isChromecastConnected) {
            throw RuntimeException("Can't send before Chromecast connection is established.")
        }
        castChannel.sendMessage(msg)
        return true
    }

    /*
     * Connection contract
     */

    fun onChromecastConnecting() {
        connectionListener.onChromecastConnecting()
    }

    fun onChromecastConnected(castSession: CastSession) {
        isChromecastConnected = true
        castSession.removeMessageReceivedCallbacks(CastPlaybackChannel.NAMESPACE)
        castSession.setMessageReceivedCallbacks(CastPlaybackChannel.NAMESPACE, castChannel)

        connectionListener.onChromecastConnected(this)
    }

    fun onChromecastDisconnected(castSession: CastSession) {
        isChromecastConnected = false
        castSession.removeMessageReceivedCallbacks(CastPlaybackChannel.NAMESPACE)

        connectionListener.onChromecastDisconnected()
    }

    fun onChromecastFailed() {
        connectionListener.onChromecastFailed()
    }

}
