package interfaceag.chrome_tube.playback_plugin.playback

import com.google.android.gms.cast.framework.*

interface CastConnectionListener {
    fun onCastConnecting()
    fun onCastConnected(context: CastPlaybackContext)
    fun onCastDisconnected()
    fun onCastFailed()
}

class CastPlaybackContext(private val castContext: CastContext, messageCallback: CastMessageCallback, private val connectionListener: CastConnectionListener) : SessionManagerListener<CastSession>, CastStateListener {

    private val castChannel = CastPlaybackChannel(castContext.sessionManager, messageCallback)
    private var isCastConnected = false

    init {
        castContext.addCastStateListener(this)
        castContext.sessionManager.addSessionManagerListener(this, CastSession::class.java)
        restoreSession()
    }

    fun dispose() {
        castContext.removeCastStateListener(this)
        castContext.sessionManager.removeSessionManagerListener(this, CastSession::class.java)
    }

    /*
     * Business methods
     */

    fun endCurrentSession(): Boolean {
        castContext.sessionManager.endCurrentSession(true)
        return true
    }

    fun sendMessage(msg: String): Boolean {
        if (!isCastConnected) {
            throw RuntimeException("Can't send before Chromecast connection is established.")
        }
        castChannel.sendMessage(msg)
        return true
    }

    /*
     * Simplified CastStates
     */

    private fun restoreSession() {
        val sessionManager = castContext.sessionManager
        if (sessionManager.currentCastSession != null) {
            onSessionResumed(sessionManager.currentCastSession, false)
        }
    }

    private fun onCastConnecting() {
        isCastConnected = false
        connectionListener.onCastConnecting()
    }

    private fun onCastConnected(castSession: CastSession) {
        isCastConnected = true
        castSession.removeMessageReceivedCallbacks(CastPlaybackChannel.NAMESPACE)
        castSession.setMessageReceivedCallbacks(CastPlaybackChannel.NAMESPACE, castChannel)

        connectionListener.onCastConnected(this)
    }

    private fun onCastDisconnected(castSession: CastSession) {
        isCastConnected = false
        castSession.removeMessageReceivedCallbacks(CastPlaybackChannel.NAMESPACE)

        connectionListener.onCastDisconnected()
    }

    private fun onCastFailed() {
        isCastConnected = false
        connectionListener.onCastFailed()
    }

    /*
     * SessionManagerListener<CastSession>, CastStateListener
     */

    override fun onSessionEnding(castSession: CastSession) {}
    override fun onSessionSuspended(castSession: CastSession, p1: Int) {}

    override fun onSessionStarting(castSession: CastSession) =
            onCastConnecting()


    override fun onSessionResuming(castSession: CastSession, p1: String) =
            onCastConnecting()


    override fun onSessionResumed(castSession: CastSession, wasSuspended: Boolean) =
            onCastConnected(castSession)

    override fun onSessionStarted(castSession: CastSession, sessionId: String) =
            onCastConnected(castSession)

    override fun onSessionEnded(castSession: CastSession, error: Int) =
            onCastDisconnected(castSession)

    override fun onSessionResumeFailed(castSession: CastSession, p1: Int) =
            onCastFailed()

    override fun onSessionStartFailed(castSession: CastSession, p1: Int) = onCastFailed()

    override fun onCastStateChanged(state: Int) {
        if (state == CastState.NOT_CONNECTED && isCastConnected) {
            onCastFailed()
        }
    }

}
