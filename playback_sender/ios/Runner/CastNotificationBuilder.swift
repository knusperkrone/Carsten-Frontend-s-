//
//  CastNotificationBuilder.swift
//  Runner
//
//  Created by IF-Lab on 20.10.20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation


///https://github.com/peantunes/google-cast-ios-lock-screen/blob/master/GoogleCastLockControls.swift
public class CastNotificationBuilder {
    
    private var player:AVPlayer?
    private var isShowing = false
    private var mediaInfo = [String : Any]()
    private var isBuffering = false;
    public var sender: PlaybackPlugin?
    
    
    @available(iOS 10.0, *)
    public func build(parsedMsg: [String: Any]) {
        switch parsedMsg["type"] as! String {
        case "N_MSG_INFO":
            if (isShowing) {
                disposePlayer()
                isShowing = false
            }
            break;
        case "N_MSG_TRACK":
            do {
                let data = Data((parsedMsg["data"] as! String).utf8)
                if let dataObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if (!isShowing) {
                        initPlayer()
                        isShowing = true;
                    }
                    
                    isBuffering = dataObj["isBuffering"] as! Bool
                    var seekMs = dataObj["seekMs"] as! Float
                    var durationMs = dataObj["durationMs"] as! Float
                    let isPlaying = dataObj["isPlaying"] as! Bool
                    let imageB64 = dataObj["coverB64"] as! String
                    let title = dataObj["title"] as! String
                    let playlistName = dataObj["playlistName"] as! String
                    let artist = dataObj["artist"] as! String
                    if (seekMs > durationMs) {
                        seekMs = 0.0
                        durationMs = 0.0
                    }
                    self.setMediaInfo(isPlaying: isPlaying, title: title, artist: artist, album: playlistName, seekMs: seekMs, durationMs: durationMs, imageB64: imageB64)
                }
            } catch {
                NSLog("\nFailed to start notification: %@", (error.localizedDescription))
            }
            break;
        default:
            NSLog("\nInvalid notification type")
        }
    }
    
    /*
     * Player alloc/free
     */
    
    @available(iOS 10.0, *)
    private func initPlayer() {
        configureCommandCenter()
        
        // Play no sound
        if let path = Bundle.main.path(forResource: "mute sound", ofType: "mp3", inDirectory: nil, forLocalization: nil){
            let url = URL.init(fileURLWithPath: path)
            let player = AVPlayer(url: url)
            player.play()
            self.player = player
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { (_) in
                DispatchQueue.main.async {
                    self.player?.seek(to: kCMTimeZero)
                    self.player?.play()
                }
            })
        }
    }
    
    @available(iOS 10.0, *)
    private func disposePlayer() {
        self.player?.pause()
        self.player?.replaceCurrentItem(with: nil)
        self.player = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
     * UI
     */
    
    @available(iOS 10.0, *)
    private func setMediaInfo(isPlaying: Bool, title:String, artist: String, album: String, seekMs:Float, durationMs:Float, imageB64:String) {
        self.mediaInfo[MPMediaItemPropertyTitle] = title
        self.mediaInfo[MPMediaItemPropertyArtist] = artist
        self.mediaInfo[MPMediaItemPropertyAlbumTitle] = album
        self.mediaInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekMs / 1000
        self.mediaInfo[MPMediaItemPropertyPlaybackDuration] = durationMs / 1000
        if (isPlaying) {
            self.player?.play()
            self.mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        } else {
            self.player?.pause()
            self.mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        }
        
        if let imageData = Data(base64Encoded: imageB64) {
            if let image = UIImage(data: imageData) {
                mediaInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (CGSize) -> UIImage in return image
                })
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
    }
    
    /*
     * Command Center
     */
    
    private func configureCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget (handler: toggle_play)
        commandCenter.pauseCommand.addTarget (handler: toggle_play)
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(handler: prevTrack)
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(handler: nextTrack)
    }
    
    private func toggle_play(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if (!isBuffering) {
            sender?.sendToBackgroundChannel(topic: NativeConstants.N_PB_TOGGLE, msg: "")
        }
        return .success
    }
    
    
    private func prevTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        sender?.sendToBackgroundChannel(topic: NativeConstants.N_PB_PREV, msg: "")
        return .success
    }
    
    private func nextTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        sender?.sendToBackgroundChannel(topic: NativeConstants.N_PB_NEXT, msg: "")
        return .success
    }
    
}
