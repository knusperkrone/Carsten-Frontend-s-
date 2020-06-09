package github.showang.flutter_google_cast_button

import androidx.annotation.StyleRes
import androidx.mediarouter.app.MediaRouteChooserDialog
import androidx.mediarouter.app.MediaRouteControllerDialog
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastState
import com.google.android.gms.cast.framework.CastStateListener
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.cast.RemoteMediaPlayer
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.Exception

class FlutterGoogleCastButtonPlugin(private val registrar: Registrar, private val castStreamHandler: CastStreamHandler) : MethodCallHandler {
    companion object {
        @StyleRes
        var customStyleResId: Int? = null
        var instance: FlutterGoogleCastButtonPlugin? = null

        private val themeResId get() = customStyleResId ?: R.style.DefaultCastDialogTheme

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val streamHandler = CastStreamHandler()
            instance = FlutterGoogleCastButtonPlugin(registrar, streamHandler)
            MethodChannel(registrar.messenger(), "flutter_google_cast_button").apply {
                setMethodCallHandler(instance)
            }
            EventChannel(registrar.messenger(), "cast_state_event").apply {
                setStreamHandler(streamHandler)
            }
        }
    }

    init {
        // Note: it raises exceptions when the current device does not have Google Play service.
        try {
            CastContext.getSharedInstance(registrar.activeContext())
        } catch (error: Exception) {
        }
    }

    private val castContext: CastContext?
        // Note: it raises exceptions when the current device does not have Google Play service.
        get() = try {
            CastContext.getSharedInstance(registrar.activeContext())
        } catch (error: Exception) {
            null
        }

    fun onResume() {
        castStreamHandler.updateState()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadMedia" -> loadMedia(call.argument("url")!!)
            "showCastDialog" -> showCastDialog()
            else -> result.notImplemented()
        }
    }

    // Shows the Chromecast dialog.
    private fun showCastDialog() {
        castContext?.let {
            it.sessionManager?.currentCastSession?.let {
                MediaRouteControllerDialog(registrar.activeContext(), themeResId)
                    .show()
            } ?: run {
                MediaRouteChooserDialog(registrar.activeContext(), themeResId).apply {
                    routeSelector = it.mergedSelector
                    show()
                }
            }
        }
    }

    private fun loadMedia(url: String) {
        val mediaInfo: MediaInfo = MediaInfo.Builder(url)
            .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
            // .setContentType("videos/mp4")
            // .setMetadata(movieMetadata)
            // .setStreamDuration(mSelectedMedia.getDuration() * 1000)
            .build()

        val remoteMediaClient: RemoteMediaClient = castContext?.sessionManager?.currentCastSession!!.remoteMediaClient
        val mediaRequest: MediaLoadRequestData = MediaLoadRequestData.Builder()
            .setMediaInfo(mediaInfo)
            .build()

        remoteMediaClient.load(mediaRequest)
    }
}

class CastStreamHandler : EventChannel.StreamHandler {

    private var lastState = CastState.NO_DEVICES_AVAILABLE
    private var eventSink: EventChannel.EventSink? = null
    private val castStateListener = CastStateListener { state ->
        lastState = state
        eventSink?.success(state)
    }

    override fun onListen(p0: Any?, sink: EventChannel.EventSink?) {
        val castContext = CastContext.getSharedInstance() ?: return
        eventSink = sink
        castContext.addCastStateListener(castStateListener)
        lastState = castContext.castState
        eventSink?.success(lastState)
    }

    override fun onCancel(p0: Any?) {
        val castContext = CastContext.getSharedInstance() ?: return
        castContext.removeCastStateListener(castStateListener)
        eventSink = null
    }

    fun updateState() {
        eventSink?.success(lastState)
    }

}
