package interfaceag.chrome_tube.playback_plugin.playback

/**
 * Implement this interface to be notified about changes in the cast mConnection.
 */
interface CastPlaybackConnectionListener {
    fun onChromecastConnecting()
    fun onChromecastConnected(context: CastPlaybackContext)
    fun onChromecastDisconnected()
    fun onChromecastFailed()
}