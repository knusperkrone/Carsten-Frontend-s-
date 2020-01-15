package interfaceag.chrome_tube.playback_plugin.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.google.android.gms.cast.framework.CastContext
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin.Companion.DISPATCHER_HANDLE_KEY
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin.Companion.SERVICE_CHANNEL_MESSAGE_NAME
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin.Companion.SERVICE_CHANNEL_METHOD_NAME
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin.Companion.SHARED_PREFS_NAME
import interfaceag.chrome_tube.playback_plugin.NativeConstants.Companion.N_CONNECTED
import interfaceag.chrome_tube.playback_plugin.NativeConstants.Companion.N_CONNECTING
import interfaceag.chrome_tube.playback_plugin.NativeConstants.Companion.N_DISCONNECTED
import interfaceag.chrome_tube.playback_plugin.NativeConstants.Companion.N_FAILED
import interfaceag.chrome_tube.playback_plugin.NativeConstants.Companion.N_SYNC
import interfaceag.chrome_tube.playback_plugin.io.EncodedMessageReceivedListener
import interfaceag.chrome_tube.playback_plugin.notification.NativeNotificationBuilder
import interfaceag.chrome_tube.playback_plugin.notification.NativeNotificationBuilder.Companion.NOTIFICATION_ID
import interfaceag.chrome_tube.playback_plugin.playback.CastPlaybackConnectionListener
import interfaceag.chrome_tube.playback_plugin.playback.CastPlaybackContext
import io.flutter.plugin.common.*
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import java.util.concurrent.atomic.AtomicBoolean


class CastConnectionService : Service(), MethodChannel.MethodCallHandler, CastPlaybackConnectionListener, EncodedMessageReceivedListener {

    companion object {
        private const val TAG = "CastConnectionService"
        @JvmStatic
        private lateinit var sPluginRegistrantCallback: PluginRegistry.PluginRegistrantCallback

        @JvmStatic
        fun setPluginRegistrant(callback: PluginRegistry.PluginRegistrantCallback) {
            sPluginRegistrantCallback = callback
        }
    }

    private val mBinder: LocalBinder = LocalBinder()
    private val mIsBackgroundInit: AtomicBoolean = AtomicBoolean(false)
    private val mIsForegroundInit: AtomicBoolean = AtomicBoolean(false)

    private lateinit var mBackgroundMethodChannel: MethodChannel
    private lateinit var mBackgroundMessageChannel: BasicMessageChannel<String>

    private var mNotiBuilder: NativeNotificationBuilder? = null
    private var mBackgroundIsolate: FlutterNativeView? = null
    private var mForegroundMethodChannel: MethodChannel? = null
    private var mForegroundMessageChannel: BasicMessageChannel<String>? = null
    private var mCastContext: CastPlaybackContext? = null

    /*
     * Lifecycle
     */

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        mNotiBuilder = NativeNotificationBuilder(applicationContext, this)
        mBackgroundIsolate = FlutterNativeView(this, true)

        // Setup plugin registry
        val registry = mBackgroundIsolate!!.pluginRegistry
        sPluginRegistrantCallback.registerWith(registry)
        // Get function entryPoint
        val handle = getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE).getLong(DISPATCHER_HANDLE_KEY, -1)
        val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(handle)
        // Run isolate
        val args = FlutterRunArguments()
        args.bundlePath = FlutterMain.findAppBundlePath()
        args.entrypoint = callbackInfo.callbackName
        args.libraryPath = callbackInfo.callbackLibraryPath
        mBackgroundIsolate!!.runFromBundle(args)

        // Register callback channels
        mBackgroundMethodChannel = MethodChannel(mBackgroundIsolate, SERVICE_CHANNEL_METHOD_NAME)
        mBackgroundMessageChannel = BasicMessageChannel<String>(mBackgroundIsolate!!, SERVICE_CHANNEL_MESSAGE_NAME, StringCodec.INSTANCE)
        mBackgroundMethodChannel.setMethodCallHandler(this)

        return START_STICKY
    }

    override fun onBind(intent: Intent?): LocalBinder {
        return mBinder
    }

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    override fun onDestroy() {
        // Stop native listeners
        mBackgroundIsolate = null
        mCastContext?.dispose()
        // Clear notification
        stopForeground(true)
        mNotiBuilder?.clear()
        mNotiBuilder = null
        stopSelf() // necessary?
        super.onDestroy()
    }

    private fun onIsolateInited() {
        if (mCastContext == null && mIsBackgroundInit.get() && mIsForegroundInit.get()) {
            mCastContext = CastPlaybackContext(CastContext.getSharedInstance(this), this, this)
        }
    }

    /*
     * Business methods
     */

    fun startUIBroadcast(methodChannel: MethodChannel, messageChannel: BasicMessageChannel<String>) {
        mForegroundMethodChannel = methodChannel
        mForegroundMessageChannel = messageChannel
        mForegroundMethodChannel!!.setMethodCallHandler(this)
        mIsForegroundInit.set(true)
        onIsolateInited()

        mBackgroundMessageChannel.send(buildIPCMessage(N_SYNC)) {
            messageChannel.send(it!!)
        }
    }

    fun stopUIBroadcast() {
        mForegroundMethodChannel?.setMethodCallHandler(null)
        mForegroundMethodChannel = null
        mForegroundMessageChannel = null
    }

    fun endConnection(): Boolean {
        return mCastContext?.endCurrentSession() ?: false
    }

    fun send(msg: String): Boolean {
        return mCastContext?.sendMessage(msg) ?: false
    }

    fun sendToBackgroundChannel(type: String, data: String) {
        sendToBackgroundChannel(buildIPCMessage(type, data))
    }

    private fun sendToBackgroundChannel(msg: String) {
        mBackgroundMessageChannel.send(msg) {
            if (it != null) {
                mNotiBuilder?.build(it)
            }
        }
    }

    /*
     * MethodCall interface + helpers
     */

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments<List<Any>>()
        when (call.method) {
            "background_isolate_inited" -> onBackgroundInit(result, args[0] as String)
            else -> result.notImplemented()
        }
    }

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    private fun onBackgroundInit(backgroundResult: MethodChannel.Result, text: String) {
        if (mNotiBuilder != null) {
            startForeground(NOTIFICATION_ID, mNotiBuilder?.buildUserNotification(text))
            mIsBackgroundInit.set(true)
            onIsolateInited()
            backgroundResult.success(true)
        } else {
            backgroundResult.error("-1", "Service was already destroyed!", "")
        }
    }

    fun restoreSession(): Boolean {
        return mCastContext?.restoreSession() ?: false
    }

    /*
     * Chromecast Interface
     */

    override fun onReceive(msg: String) {
        sendToBackgroundChannel(msg)
        mForegroundMessageChannel?.send(msg)
    }

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    override fun onChromecastConnecting() {
        Log.d(TAG, "onChromecastConnecting")
        sendToBackgroundChannel(buildIPCMessage(N_CONNECTING))
    }

    override fun onChromecastConnected(context: CastPlaybackContext) {
        Log.d(TAG, "onChromecastConnected")
        val msg = buildIPCMessage(N_CONNECTED)
        sendToBackgroundChannel(msg)
        mForegroundMessageChannel?.send(msg)
    }

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    override fun onChromecastDisconnected() {
        Log.d(TAG, "onChromecastDisconnected")
        val msg = buildIPCMessage(N_DISCONNECTED)
        mForegroundMessageChannel?.send(msg)
        sendToBackgroundChannel(msg)
    }

    @RequiresApi(Build.VERSION_CODES.ECLAIR)
    override fun onChromecastFailed() {
        Log.d(TAG, "onChromecastFailed")
        val msg = buildIPCMessage(N_FAILED)
        mForegroundMessageChannel?.send(msg)
        sendToBackgroundChannel(msg)
    }

    private fun buildIPCMessage(type: String, data: String = ""): String =
            "{\"type\":\"$type\",\"$data\":\"\"}"

    /*
     * Helper class
     */

    inner class LocalBinder : Binder() {
        val service: CastConnectionService
            get() = this@CastConnectionService
    }

}