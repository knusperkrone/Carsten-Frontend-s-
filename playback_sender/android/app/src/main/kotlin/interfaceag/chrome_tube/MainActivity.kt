package interfaceag.chrome_tube

import android.view.KeyEvent
import androidx.annotation.NonNull
import com.tekartik.sqflite.SqflitePlugin
import github.showang.flutter_google_cast_button.FlutterGoogleCastButtonPlugin
import interfaceag.chrome_tube.playback_plugin.CastPlaybackContextPlugin
import interfaceag.chrome_tube.playback_plugin.service.CastConnectionService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin


class MainActivity : FlutterActivity(), CastConnectionService.RegistryCallback {

    private val castPlugin = CastPlaybackContextPlugin()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
        CastConnectionService.setPluginRegistrant(this)
        flutterEngine.plugins.add(castPlugin)
    }

    override fun registerWith(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(PathProviderPlugin())
        flutterEngine.plugins.add(SharedPreferencesPlugin())
        flutterEngine.plugins.add(SqflitePlugin())
        flutterEngine.plugins.add(castPlugin)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        var handled: Boolean? = false
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            handled = castPlugin.sendVolumeDown()
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            handled = castPlugin.sendVolumeUp()
        }
        if (handled == true) {
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onResume() {
        super.onResume()
        castPlugin.onResume()
        FlutterGoogleCastButtonPlugin.instance?.onResume()
    }

    override fun onPause() {
        super.onPause()
        castPlugin.onPause()
    }

    override fun onDestroy() {
        castPlugin.onDestroy()
        super.onDestroy()
    }
}
