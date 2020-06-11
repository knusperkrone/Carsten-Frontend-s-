import UIKit
import Flutter
import GoogleCast

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let kReceiverAppID = "780E142E"
    let kDebugLoggingEnabled = false
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Enable Chromecast support
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        GCKLogger.sharedInstance().delegate = self // logger
       
        // Get foreground channel
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let foregroundMessageChannel = FlutterBasicMessageChannel(name: "interfaceag/cast_context/service_message", binaryMessenger: controller.binaryMessenger, codec: FlutterStringCodec.sharedInstance())
        
        // Register app plugin
        PlaybackPlugin.register(with: self.registrar(forPlugin: "interface_ag.cast_plugin"))
        PlaybackPlugin.foregroundBroadcast(channel: foregroundMessageChannel)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        PlaybackPlugin.instance?.onForeground()
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        PlaybackPlugin.instance?.onBackground()
    }
}

extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        if(kDebugLoggingEnabled) {
            NSLog("\n" + function + " - " + message)
        }
    }
}
