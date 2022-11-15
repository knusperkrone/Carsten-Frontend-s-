package interfaceag.chrome_tube.playback_plugin

import android.content.Context
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider

class CastOptionsProvider : OptionsProvider {

    companion object {
        const val RECEIVER_ID = "780E142E"
        const val DESCRIPTION = "chromecast-youtube-player-receiver"
    }

    override fun getCastOptions(p0: Context): CastOptions =
            CastOptions.Builder().setReceiverApplicationId(RECEIVER_ID).build()

    override fun getAdditionalSessionProviders(p0: Context): MutableList<SessionProvider>? = null
}