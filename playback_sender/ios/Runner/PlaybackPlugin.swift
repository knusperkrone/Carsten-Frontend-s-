//
//  PlaybackPlugin.swift
//  Runner
//
//  Created by IF-Lab on 11.06.20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

struct NativeConstants {
    // CONNECTION IPC
    static let N_CONNECTING = "N_CONNECTING"
    static let N_CONNECTED = "N_CONNECTED"
    static let N_DISCONNECTED = "N_DISCONNECTED"
    static let N_FAILED = "N_FAILED"
    // FOREGROUND/BACKGROUND IPC
    static let N_SYNC = "N_SYNC"
    // NOTIFICATION TYPE
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

public class PlaybackPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CastConnectionListener {
    public static var instance: PlaybackPlugin?
    
    let channelMessageName = "interfaceag/cast_context/service_message"
    let bgChannelMethodName = "interfaceag/cast_context/service_method"
    let kNameSpace = "urn:x-cast:com.pierfrancescosoffritti.androidyoutubeplayer.chromecast.communication"
    let kDebugLoggingEnabled = false
    
    var eventSink: FlutterEventSink? = nil
    var foregroundMessageChannel: FlutterBasicMessageChannel? = nil
    var backgroundMessageChannel: FlutterBasicMessageChannel? = nil
    var castContext: CastContext?
    var isForeground = true
    
    /*
     * Plugin contract
     */
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let eventName = "interfaceag/cast_context_plugin_event"
        let channelMethodName = "interfaceag/cast_context_plugin"
        if (instance == nil) {
            instance = PlaybackPlugin()
        }
        let channel = FlutterMethodChannel(name: channelMethodName, binaryMessenger: registrar.messenger())
        let event = FlutterEventChannel(name: eventName, binaryMessenger: registrar.messenger())
        event.setStreamHandler(instance!)
        registrar.addMethodCallDelegate(instance!, channel: channel)
    }
    
    public static func foregroundBroadcast(channel: FlutterBasicMessageChannel) {
        instance?.foregroundMessageChannel = channel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        case "set_volumne":
            self.onSetVolume(result: result, volume: arguments[0] as! NSNumber)
            break
        case "volume_up":
            break
        case "volume_down":
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /*
     * Dart callbacks
     */
    
    private func onInit(foregroundResult: @escaping FlutterResult, startId: NSNumber) {
        let backgroundIsolate = FlutterEngine.init(name: "CarstenIsolate", project: nil, allowHeadlessExecution: true)
        
        // Register callback channels
        backgroundMessageChannel = FlutterBasicMessageChannel(name: channelMessageName, binaryMessenger: backgroundIsolate.binaryMessenger, codec: FlutterJSONMessageCodec.sharedInstance())
        let backgroundMethodChannel = FlutterMethodChannel(name: bgChannelMethodName, binaryMessenger: backgroundIsolate.binaryMessenger)
        // Run isolate
        let info = FlutterCallbackCache.lookupCallbackInformation(startId.int64Value)
        let entrypoint = info!.callbackName
        let uri = info!.callbackLibraryPath
        backgroundIsolate.run(withEntrypoint: entrypoint, libraryURI: uri)
        // Setup plugin registry
        PlaybackPlugin.register(with: backgroundIsolate.registrar(forPlugin: "interface_ag.cast_plugin"))
        GeneratedPluginRegistrant.register(with: backgroundIsolate)
        
        // Set method handler
        backgroundMethodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            NSLog("\nBackgroundCalled: %@", call.method)
            guard call.method == "background_isolate_inited" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self.castContext = CastContext.init(namespace: self.kNameSpace, listener: self)
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
    
    private func onSetVolume(result: FlutterResult, volume: NSNumber) {
        let ret = castContext?.setVolume(volume: volume.doubleValue) ?? 0.0
        result(ret)
    }
    
    private func onVolumeUp(result: FlutterResult) {
        let ret = castContext?.volumeUp() ?? 0.0
        result(ret)
    }
    
    private func onVolumeDown(result: FlutterResult) {
        let ret = castContext?.volumeDown() ?? 0.0
        result(ret)
    }
    
    /*
     * App Lifecycle
     */
    
    public func onForeground() {
        // Sync foreground isolate
        backgroundMessageChannel?.sendMessage(buildIPCMessage(type:NativeConstants.N_SYNC), reply: { (reply) in
            self.foregroundMessageChannel?.sendMessage(reply)
            self.isForeground = true
        })
    }
    
    public func onBackground() {
        isForeground = false
    }
    
    /*
     * Listener Contract
     */
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    /*
     * Cast Lifecycle
     */
    
    public func onMsg(msg: String) {
        // Dispatch native message
        NSLog("\nMSG: %@", msg)
        let data = Data(msg.utf8)
        do {
            if let parsedMsg = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if (isForeground) {
                    foregroundMessageChannel?.sendMessage(parsedMsg)
                }
                sendToBackground(msg: parsedMsg)
            }
        } catch let error as NSError {
            print("Failed to send: \(error.localizedDescription)")
        }
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
    
    /*
     * Helpers
     */
    
    private func buildIPCMessage(type: String) -> [String: Any] {
        return buildIPCMessage(type: type, data: "")
    }
    
    private func buildIPCMessage(type: String, data: String) -> [String: Any] {
        return [
            "type": type,
            "data": data,
        ]
    }
    
    private func sendToBackground(msg: [String: Any]) {
        backgroundMessageChannel?.sendMessage(msg)
    }
}
