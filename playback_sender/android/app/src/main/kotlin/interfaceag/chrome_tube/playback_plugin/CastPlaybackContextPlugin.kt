package interfaceag.chrome_tube.playback_plugin

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi
import interfaceag.chrome_tube.playback_plugin.service.CastConnectionService
import io.flutter.plugin.common.*

/*
 * https://medium.com/flutter/executing-dart-in-the-background-with-flutter-plugins-and-geofencing-2b3e40a1a124
 */
class CastPlaybackContextPlugin(private val mContext: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "CastPlaybackCxtPlugin"
        private const val CHANNEL_NAME = "interfaceag/cast_context_plugin"
        private const val EVENT_NAME = "interfaceag/cast_context_plugin_event"

        internal const val SERVICE_CHANNEL_METHOD_NAME = "interfaceag/cast_context/service_method"
        internal const val SERVICE_CHANNEL_MESSAGE_NAME = "interfaceag/cast_context/service_message"
        internal const val SHARED_PREFS_NAME = "interfaceag_cast_context_prefs"
        internal const val DISPATCHER_HANDLE_KEY = "entry_handle_key"

        var instance: CastPlaybackContextPlugin? = null

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            if (instance == null) {
                instance = CastPlaybackContextPlugin(registrar.context(), registrar.messenger())
            }
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val event = EventChannel(registrar.messenger(), EVENT_NAME)
            channel.setMethodCallHandler(instance)
            event.setStreamHandler(instance!!.mServiceConnection)
        }
    }

    private var mIsBound = false
    private var mIsInited = false
    private val mServiceConnection = ResultServiceConnection(messenger)

    /*
     * lifecycle method
     */

    fun onResume() {
        if (mIsInited) {
            val serviceIntent = Intent(mContext, CastConnectionService::class.java)
            mContext.bindService(serviceIntent, mServiceConnection, Context.BIND_AUTO_CREATE)
            mIsBound = true
        }
    }

    fun onPause() {
        if (mIsInited && mIsBound) {
            mContext.unbindService(mServiceConnection)
            mIsBound = false
        }
    }

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    fun onDestroy() {
        instance = null
        if (mIsInited) {
            mIsInited = false
            if (mIsBound) {
                mContext.unbindService(mServiceConnection)
            }
            mIsBound = false
            val serviceIntent = Intent(mContext, CastConnectionService::class.java)
            mContext.stopService(serviceIntent)
        }
    }

    /*
     * Business methods
     */

    fun sendVolumeUp(): Boolean {
        if (mServiceConnection.service?.isConnected() == true) {
            mServiceConnection.eventSink?.success("UP")
            return true
        }
        return false
    }

    fun sendVolumeDown(): Boolean {
        if (mServiceConnection.service?.isConnected() == true) {
            mServiceConnection.eventSink?.success("DOWN")
            return true
        }
        return false
    }

    /*
     * MethodCall interface + helpers
     */

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: " + call.method)
        val args = call.arguments() as? ArrayList<*>
        when (call.method) {
            "init" -> onInit(args, result)
            "send_msg" -> onSend(args, result)
            "end" -> onEnd(result)
            "set_volume" -> onSetVolume(args, result)
            "volume_up" -> onVolumeUp(result)
            "volume_down" -> onVolumeDown(result)
            else -> result.notImplemented()
        }
    }

    private fun onInit(args: ArrayList<*>?, result: MethodChannel.Result) {
        // Persist key - so system can kill service
        val handle = args!![0] as Long
        if (!mContext.getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE)
                        .edit()
                        .putLong(DISPATCHER_HANDLE_KEY, handle)
                        .commit()) {
            result.error("-2", "No background entrypoint provided!", "")
            return
        }

        val serviceIntent = Intent(mContext, CastConnectionService::class.java)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                mContext.startForegroundService(serviceIntent)
            } else {
                mContext.startService(serviceIntent) // Call on create
            }
        } catch (e: RuntimeException) {
            Log.e(TAG, e.toString())
            result.success(false)
            return
        }
        mServiceConnection.result = result
        mContext.bindService(serviceIntent, mServiceConnection, Context.BIND_AUTO_CREATE)
        mIsBound = true
        mIsInited = true
    }

    private fun onEnd(result: MethodChannel.Result) {
        if (!mIsInited) {
            result.error("-1", "Service not inited", "")
        } else {
            result.success(mServiceConnection.service?.endConnection() ?: false)
        }
    }

    private fun onSend(args: ArrayList<*>?, result: MethodChannel.Result) {
        if (!mIsInited) {
            result.error("-1", "Service not inited", "")
        } else {
            result.success(mServiceConnection.service?.send(args!![0] as String) ?: false)
        }
    }


    private fun onSetVolume(args: ArrayList<*>?, result: MethodChannel.Result) {
        if (!mIsInited) {
            result.error("-1", "Service not inited", "")
        } else {
            result.success(mServiceConnection.service?.setVolume(args!![0] as Double) ?: 0.0)
        }
    }

    private fun onVolumeUp(result: MethodChannel.Result) {
        if (!mIsInited) {
            result.error("-1", "Service not inited", "")
        } else {
            result.success(mServiceConnection.service?.volumeUp() ?: 0.0)
        }
    }

    private fun onVolumeDown(result: MethodChannel.Result) {
        if (!mIsInited) {
            result.error("-1", "Service not inited", "")
        } else {
            result.success(mServiceConnection.service?.volumeDown() ?: 0.0)
        }
    }

}

class ResultServiceConnection(messenger: BinaryMessenger) : ServiceConnection, EventChannel.StreamHandler {
    private val mForegroundMethodChannel = MethodChannel(messenger, CastPlaybackContextPlugin.SERVICE_CHANNEL_METHOD_NAME)
    private val mForegroundMessageChannel = BasicMessageChannel<Any>(messenger, CastPlaybackContextPlugin.SERVICE_CHANNEL_MESSAGE_NAME, JSONMessageCodec.INSTANCE)

    var eventSink: EventChannel.EventSink? = null
    var result: MethodChannel.Result? = null
    var service: CastConnectionService? = null

    override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
        service = (binder as CastConnectionService.LocalBinder).service
        service!!.initUIBroadcast(mForegroundMessageChannel)
        result?.success(true)
        result = null
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        mForegroundMethodChannel.setMethodCallHandler(null)
        service!!.pauseUIBroadcast()
    }

    override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
        eventSink = sink;
    }

    override fun onCancel(args: Any?) {
        eventSink = null;
    }
}
