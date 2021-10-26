package de.intere.flutter_cast_button

import android.content.Context
import androidx.annotation.NonNull
import androidx.mediarouter.app.MediaRouteChooserDialog
import androidx.mediarouter.app.MediaRouteControllerDialog
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastState
import com.google.android.gms.cast.framework.CastStateListener
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import io.flutter.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference

/** FlutterCastButtonPlugin */
class FlutterCastButtonPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var castContext: CastContext
    private lateinit var streamHandler: CastStreamHandler

    private var context = WeakReference<Context>(null)
    private val themeResId = R.style.Theme_AppCompat_DayNight_Dialog

    /*
     * FlutterPlugin contract
     */

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = WeakReference(flutterPluginBinding.applicationContext)

        try {
            castContext = CastContext.getSharedInstance(context.get()!!)
        } catch (error: Exception) {
            Log.e("FlutterCastButton", "Init castContext", error)
        }

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_cast_button")
        channel.setMethodCallHandler(this)

        streamHandler = CastStreamHandler()
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "cast_state_event")
        eventChannel.setStreamHandler(streamHandler)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        context.clear()
    }

    /*
     * Lifecycle
     */

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        context = WeakReference(binding.activity)
        streamHandler.updateState()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        context.clear()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        context = WeakReference(binding.activity)
        streamHandler.updateState()
    }

    override fun onDetachedFromActivity() {
        context.clear()
    }

    /*
     * MethodCallHandler contract
     */

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "loadMedia" -> loadMedia(call.argument("url")!!)
            "showCastDialog" -> showCastDialog()
            else -> result.notImplemented()
        }
    }

    private fun showCastDialog() {
        castContext.sessionManager.currentCastSession?.let {
            MediaRouteControllerDialog(context.get()!!, themeResId).show()
        } ?: run {
            MediaRouteChooserDialog(context.get()!!, themeResId).apply {
                routeSelector = castContext.mergedSelector!!
                show()
            }
        }
    }

    private fun loadMedia(url: String) {
        val mediaInfo: MediaInfo = MediaInfo.Builder(url)
            .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
            .build()

        val remoteMediaClient: RemoteMediaClient =
            castContext.sessionManager.currentCastSession!!.remoteMediaClient!!
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

