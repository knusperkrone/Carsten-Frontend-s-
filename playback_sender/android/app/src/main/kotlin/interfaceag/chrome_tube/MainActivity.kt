package interfaceag.chrome_tube

import android.os.Bundle
import androidx.core.app.NotificationManagerCompat
import github.showang.flutter_google_cast_button.FlutterGoogleCastButtonPlugin
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin
import interfaceag.chrome_tube.playback_plugin.service.CastConnectionService
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CastConnectionService.setPluginRegistrant(this)
        CastPlaybackContextPlugin.registerWith(registrarFor("interfaceag.chrome_tube.cast_plugin.CastPlaybackContextPlugin"))
        GeneratedPluginRegistrant.registerWith(this)
    }

    override fun registerWith(registrant: PluginRegistry) {
        CastPlaybackContextPlugin.registerWith(registrant.registrarFor("interfaceag.chrome_tube.cast_plugin.CastPlaybackContextPlugin"))
        GeneratedPluginRegistrant.registerWith(registrant)
    }

    override fun onResume() {
        super.onResume()
        CastPlaybackContextPlugin.instance?.onResume()
        FlutterGoogleCastButtonPlugin.instance?.onResume()
    }

    override fun onPause() {
        super.onPause()
        CastPlaybackContextPlugin.instance?.onPause()
    }

    override fun onDestroy() {
        CastPlaybackContextPlugin.instance?.onDestroy()
        super.onDestroy()
    }
}
