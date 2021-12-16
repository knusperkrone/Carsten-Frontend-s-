package interfaceag.chrome_tube.playback_plugin.playback

import android.os.Handler
import android.os.Looper
import androidx.mediarouter.media.MediaRouteSelector
import androidx.mediarouter.media.MediaRouter
import com.google.android.gms.cast.CastDevice
import com.google.android.gms.cast.CastMediaControlIntent
import com.google.android.gms.cast.framework.*
import interfaceag.chrome_tube.playback_plugin.CastOptionsProvider
import kotlin.math.max
import kotlin.math.min

interface CastConnectionListener {
    fun onCastConnecting()
    fun onCastConnected(context: CastPlaybackContext)
    fun onCastDisconnected()
    fun onCastFailed()
}

class CastPlaybackContext(private val router: MediaRouter, private val castContext: CastContext, messageCallback: CastMessageCallback, private val connectionListener: CastConnectionListener) : SessionManagerListener<CastSession>, CastStateListener {

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

    fun isConnected(): Boolean = castContext.sessionManager.currentCastSession != null

    fun setVolume(volume: Double): Double {
        castContext.sessionManager.currentCastSession?.volume = volume
        return volume
    }

    fun volumeUp(): Double? {
        val session = castContext.sessionManager.currentCastSession
        if (session != null) {
            val newVolume = min(1.0, session.volume + 0.04)
            session.volume = newVolume
            return newVolume
        }
        return castContext.sessionManager.currentCastSession?.volume
    }

    fun volumeDown(): Double? {
        val session = castContext.sessionManager.currentCastSession
        if (session != null) {
            val newVolume = max(0.0, session.volume - 0.04)
            session.volume = newVolume
            return newVolume
        }
        return castContext.sessionManager.currentCastSession?.volume
    }

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

    private fun checkRoute(route: MediaRouter.RouteInfo?): Boolean {
        if (route?.extras != null) {
            val device = CastDevice.getFromBundle(route.extras)
            if (device != null && route.description == "SpotiTube") {
                return true
            }
        }
        return false
    }

    private fun restoreSession() {
        val sessionManager = castContext.sessionManager
        if (sessionManager.currentCastSession != null) {
            onSessionResumed(sessionManager.currentCastSession!!, false)
        } else {
            val selector = MediaRouteSelector.Builder()
                    .addControlCategory(CastMediaControlIntent.categoryForCast(CastOptionsProvider.RECEIVER_ID))
                    .build()

            val available = router.isRouteAvailable(selector, MediaRouter.AVAILABILITY_FLAG_IGNORE_DEFAULT_ROUTE)
            if (available) {
                for (route in router.routes) {
                    if (checkRoute(route)) {
                        router.selectRoute(route!!)
                    }
                }
            } else {
                val callback: MediaRouter.Callback = object : MediaRouter.Callback() {
                    override fun onRouteAdded(router: MediaRouter?, route: MediaRouter.RouteInfo?) {
                        if (checkRoute(route)) {
                            router?.selectRoute(route!!)
                        }
                        super.onRouteAdded(router, route)
                    }
                }
                // Perform active-scan for 2500ms
                router.addCallback(selector, callback, MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN)
                Handler(Looper.getMainLooper()).postDelayed({ router.removeCallback(callback) }, 2500)
            }
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
