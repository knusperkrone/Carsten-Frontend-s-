package interfaceag.chrome_tube

import android.os.Bundle
import android.view.KeyEvent
import androidx.core.app.NotificationManagerCompat
import com.tekartik.sqflite.SqflitePlugin
import github.showang.flutter_google_cast_button.FlutterGoogleCastButtonPlugin
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin
import interfaceag.chrome_tube.playback_plugin.service.CastConnectionService
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin


class MainActivity : FlutterActivity(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CastConnectionService.setPluginRegistrant(this)
        CastPlaybackContextPlugin.registerWith(registrarFor("interfaceag.chrome_tube.cast_plugin.CastPlaybackContextPlugin"))
        GeneratedPluginRegistrant.registerWith(this)
    }

    override fun registerWith(registrant: PluginRegistry) {
        CastPlaybackContextPlugin.registerWith(registrant.registrarFor("interfaceag.chrome_tube.cast_plugin.CastPlaybackContextPlugin"))
        PathProviderPlugin.registerWith(registrant.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
        SharedPreferencesPlugin.registerWith(registrant.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
        SqflitePlugin.registerWith(registrant.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        var handled: Boolean? = false
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            handled = CastPlaybackContextPlugin.instance?.sendVolumeDown()
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            handled = CastPlaybackContextPlugin.instance?.sendVolumeUp()
        }
        if (handled == true) {
            return true
        }
        return super.onKeyDown(keyCode, event)
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
