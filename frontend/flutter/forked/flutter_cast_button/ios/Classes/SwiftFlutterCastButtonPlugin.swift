import Flutter
import GoogleCast

public class SwiftFlutterCastButtonPlugin: NSObject, FlutterPlugin {
    let castContext = GCKCastContext.sharedInstance()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_cast_button", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCastButtonPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "cast_state_event", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(CastEventHandler())
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showCastDialog":
            castContext.presentCastDialog()
            break;
        default:
            print("Method [\(call.method)] is not implemented.")
        }
        result(true)
    }
}

class CastEventHandler: NSObject,FlutterStreamHandler {
    
    private static var eventSink: FlutterEventSink? = nil
    let castContext = GCKCastContext.sharedInstance()
    var lastState = GCKCastState.notConnected
    var stateObserver: NSKeyValueObservation?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        CastEventHandler.eventSink = events
        stateObserver = castContext.observe(\.castState, options: [.new, .old, .initial]){ (state, change) in
            self.lastState = self.castContext.castState
            print("cast state change to: \(self.lastState.rawValue)")
            CastEventHandler.eventSink?(self.lastState.rawValue + 1)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stateObserver?.invalidate()
        stateObserver = nil
        CastEventHandler.eventSink = nil
        return nil
    }
    
}


