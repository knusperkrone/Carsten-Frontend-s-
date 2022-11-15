//
//  CastContext.swift
//  Runner
//
//  Created by IF-Lab on 10.06.20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import GoogleCast


class CastPlaybackChannel: GCKCastChannel {
    var callback: (String) -> Void = { (msg) -> Void in }
    
    public func add(callback: @escaping (String) -> Void) {
        self.callback = callback
    }
    
    override func didReceiveTextMessage(_ message: String) {
        callback(message)
    }
}

class CastContext: NSObject {
    let channel: CastPlaybackChannel
    let context: GCKCastContext
    let listener: CastConnectionListener
    var castConnected = false
    
    init(namespace: String, listener: CastConnectionListener) {
        self.listener = listener
        channel = CastPlaybackChannel(namespace: namespace)
        channel.add(callback: listener.onMsg)
        context = GCKCastContext.sharedInstance()
        super.init()
        context.sessionManager.add(self)
        restoreSession()
    }
    
    public func setVolume(volume: Double) -> Double? {
        context.sessionManager.currentCastSession?.setDeviceVolume(Float(volume))
        return volume
    }
    
    public func volumeUp() -> Double? {
        let session = context.sessionManager.currentCastSession
        if (session != nil) {
            let newVolume = min(1.0, session!.currentDeviceVolume + 0.04)
            session?.setDeviceVolume(newVolume)
            return Double(newVolume)
        }
        return nil
    }
    
    public func volumeDown() -> Double? {
        let session = context.sessionManager.currentCastSession
        if (session != nil) {
            let newVolume = max(0.0, session!.currentDeviceVolume - 0.04)
            session?.setDeviceVolume(newVolume)
            return Double(newVolume)
        }
        return nil
    }
 
    public func sendMessage(msg: String) -> Bool{
        if (!castConnected) {
            return false
        }
        channel.sendTextMessage(msg, error: nil)
        return true
    }
    
    public func endSession() -> Bool {
        context.sessionManager.endSessionAndStopCasting(true)
        return true
    }
    
    private func restoreSession() {
        let sessionManager = context.sessionManager
        if (sessionManager.currentSession != nil) {
            self.sessionManager(sessionManager, didResumeCastSession: sessionManager.currentSession as! GCKCastSession)
        }
    }
    
    private func onCastConnecting() {
        castConnected = false
        listener.onCastConnecting()
    }
    
    private func onCastConnected(session: GCKCastSession) {
        castConnected = true
        
        // Add channel and callbacks
        session.remove(channel)
        session.add(channel)
        listener.onCastConnected()
    }
    
    private func onCastDisconnected(session: GCKCastSession) {
        castConnected = false
        session.remove(channel)
        listener.onCastDisconnected()
    }
    
    private func onCastFailed() {
        castConnected = false
        listener.onCastFailed()
    }
}

extension CastContext: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        onCastConnected(session: session)
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        onCastConnecting()
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        onCastConnected(session: session)
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKSession) {
        //self.onCastDisconnected(session: session)
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKCastSession, withError error: Error?) {
        onCastDisconnected(session: session)
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        onCastFailed()
    }
}
