import UIKit
import Flutter
import GoogleCast

struct NativeConstants {
    static let N_CONNECTING = "N_CONNECTING"
    static let N_CONNECTED = "N_CONNECTED"
    static let N_DISCONNECTED = "N_DISCONNECTED"
    static let N_FAILED = "N_FAILED"
    
    static let N_SYNC = "N_SYNC"
    
    static let N_MSG_INFO = "N_MSG_INFO"
    static let N_MSG_TRACK = "N_MSG_TRACK"
    
    static let N_PB_TOGGLE = "N_PB_TOGGLE"
    static let N_PB_NEXT = "N_PB_NEXT"
    static let N_PB_PREV = "N_PB_PREV"
    static let N_PB_STOP = "N_PB_STOP"
}

protocol CastConnectionListener {
    func onMsg(msg: String)
    func onCastConnecting()
    func onCastConnected()
    func onCastDisconnected()
    func onCastFailed()
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CastConnectionListener {
    let bgChannelMethodName = "interfaceag/cast_context/service_method"
    let bgChannelMessageName = "interfaceag/cast_context/service_message"
    let kReceiverAppID = "780E142E"
    let kNameSpace = "urn:x-cast:com.pierfrancescosoffritti.androidyoutubeplayer.chromecast.communication"
    let kDebugLoggingEnabled = false
    
    var foregroundMessageChannel: FlutterBasicMessageChannel? = nil
    var backgroundMessageChannel: FlutterBasicMessageChannel? = nil
    var castContext: CastPlaybackContext?
    var isForeground = true
    var tmp = 0
    
    /*
     * Dart callbacks
     */
    
    private func onInit(foregroundResult: @escaping FlutterResult, startId: NSNumber) {
        let backgroundIsolate = FlutterEngine.init(name: "CarstenIsolate", project: nil, allowHeadlessExecution: true)
        
        // Register callback channels
        backgroundMessageChannel = FlutterBasicMessageChannel(name: bgChannelMessageName, binaryMessenger: backgroundIsolate.binaryMessenger, codec: FlutterStringCodec.sharedInstance())
        let backgroundMethodChannel = FlutterMethodChannel(name: bgChannelMethodName, binaryMessenger: backgroundIsolate.binaryMessenger)
        // Run isolate
        let info = FlutterCallbackCache.lookupCallbackInformation(startId.int64Value)
        let entrypoint = info!.callbackName
        let uri = info!.callbackLibraryPath
        backgroundIsolate.run(withEntrypoint: entrypoint, libraryURI: uri)
        // Setup plugin registry
        GeneratedPluginRegistrant.register(with: backgroundIsolate)
        
        // Set method handler
        backgroundMethodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            NSLog("\nBackgroundCalled: %@", call.method)
            self.castContext = CastPlaybackContext.init(namespace: self.kNameSpace, listener: self)
            foregroundResult(true)
            result(true)
        })
    }
    
    private func onEnd(result: FlutterResult) {
        let ret = castContext?.endSession() ?? false
        result(ret)
    }
    
    private func onSend(result: FlutterResult, msg: String) {
        let ret = castContext?.sendMessage(msg: msg) ?? false
        result(ret)
    }
    
    /*
     * Cast Lifecycle
     */
    
    public func onMsg(msg: String) {
        // Dispatch native message
        NSLog("\nMSG: %@", msg)
        if (isForeground) {
            foregroundMessageChannel?.sendMessage(msg)
        }
        sendToBackground(msg: msg)
    }
    
    public func onCastConnecting() {
        NSLog("\nonCastConnecting")
        sendToBackground(msg: buildIPCMessage(type: NativeConstants.N_CONNECTING))
    }
    
    public func onCastConnected() {
        NSLog("\nonCastConnected")
        sendToBackground(msg: buildIPCMessage(type: NativeConstants.N_CONNECTED))
    }
    
    public func onCastDisconnected() {
        NSLog("\nonCastDisconnected")
        sendToBackground(msg: buildIPCMessage(type: NativeConstants.N_DISCONNECTED))
    }
    
    public func onCastFailed() {
        NSLog("\nonCastFailed")
        sendToBackground(msg: buildIPCMessage(type: NativeConstants.N_FAILED))
    }
    
    private func buildIPCMessage(type: String) -> String {
        return buildIPCMessage(type: type, data: "")
    }
    
    private func buildIPCMessage(type: String, data: String) -> String {
        return String.init(format: "{\"type\":\"%@\",\"data\":\"%@\"}", type, data)

    }
    
    private func sendToBackground(msg: String) {
        backgroundMessageChannel?.sendMessage(msg)
    }
    
    /*
     * App Lifecycle
     */
    
    override func applicationWillResignActive(_ application: UIApplication) {
        isForeground = false
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        isForeground = true
        // Sync foreground isolate
        //backgroundMessageChannel?.sendMessage(NativeConstants.N_SYNC, reply: { (reply) in
        //    self.foregroundMessageChannel?.sendMessage(reply)
        //})
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Chromecast
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        // Enable logger
        GCKLogger.sharedInstance().delegate = self
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        // Init channels
        foregroundMessageChannel = FlutterBasicMessageChannel(name: "interfaceag/cast_context/service_message", binaryMessenger: controller.binaryMessenger, codec: FlutterStringCodec.sharedInstance())
        let foregroundMethodChannel = FlutterMethodChannel(name: "interfaceag/cast_context_plugin",
                                                           binaryMessenger: controller.binaryMessenger)
        foregroundMethodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            NSLog("\nCalled: %@", call.method)
            let arguments: Array = call.arguments as! Array<Any>
            switch call.method {
            case "init":
                self.onInit(foregroundResult: result, startId: arguments[0] as! NSNumber)
                break
            case "end":
                self.onEnd(result: result)
                break
            case "send_msg":
                self.onSend(result: result, msg:  arguments[0] as! String)
                break
            default:
                result(true)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}

extension AppDelegate: GCKLoggerDelegate {
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        if(kDebugLoggingEnabled) {
            NSLog("\n" + function + " - " + message)
        }
    }
}
