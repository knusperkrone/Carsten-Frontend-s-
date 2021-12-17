package interfaceag.chrome_tube.playback_plugin.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import interfaceag.chrome_tube.playback_plugin.NativeConstants
import interfaceag.chrome_tube.playback_plugin.service.CastConnectionService


class PlaybackNotificationReceiver(private val mService: CastConnectionService) : BroadcastReceiver() {

    companion object {
        private const val TAG = "PlaybackBroadcastRec"

        const val PLAY_INTENT_NAME = "interfaceag.chrome_tube.PLAY"
        const val NEXT_INTENT_NAME = "interfaceag.chrome_tube.NEXT"
        const val PREVIOUS_INTENT_NAME = "interfaceag.chrome_tube.PREVIOUS"
        const val STOP_INTENT_NAME = "interfaceag.chrome_tube.STOP"
        const val NOP_INTENT_NAME = "interfaceag.chrome_tube.NOP"
        internal const val INTENT_REQUEST_CODE = 255
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            PLAY_INTENT_NAME -> mService.sendToBackgroundChannel(NativeConstants.N_PB_TOGGLE, "")
            NEXT_INTENT_NAME -> mService.sendToBackgroundChannel(NativeConstants.N_PB_NEXT, "")
            PREVIOUS_INTENT_NAME -> mService.sendToBackgroundChannel(NativeConstants.N_PB_PREV, "")
            STOP_INTENT_NAME -> mService.sendToBackgroundChannel(NativeConstants.N_PB_STOP, "")
            else -> Log.e(TAG, "Invalid action provided!")
        }
    }

}
