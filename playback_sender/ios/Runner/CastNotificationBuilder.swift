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


public class CastNotificationBuilder {
    
    private var isShowing = false
    private var mediaInfo = [String : Any]()
    
    public func build(parsedMsg: [String: Any]) {
        /*
        switch parsedMsg["type"] as! String {
        case "N_MSG_INFO":
            break;
        case "N_MSG_TRACK":
            do {
                let data = Data((parsedMsg["data"] as! String).utf8)
                
                if let dataObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //dataObj["isBuffering"] as! Bool;
                    //dataObj["isPlaying"] as! Bool;
                    //dataObj["coverB64"] as! String;
                    //dataObj["title"] as! String;
                    //dataObj["playlistName"] as! String;
                    //dataObj["artist"] as! String;
                    do {
                        if (!isShowing) {
                            let mediaController = MPMusicPlayerController.applicationMusicPlayer
                            mediaController.beginGeneratingPlaybackNotifications()
                            
                            let session = AVAudioSession.sharedInstance()
                            try session.setCategory(AVAudioSessionCategoryPlayback)
                            try session.setActive(true)
                            isShowing = true;
                        }
                        
                        mediaInfo[MPMediaItemPropertyTitle] = dataObj["title"] as! String;
                        mediaInfo[MPMediaItemPropertyArtist] = dataObj["artist"] as! String;
                        mediaInfo[MPMediaItemPropertyAlbumTitle] = dataObj["playlistName"] as! String;
                        mediaInfo[MPMediaItemPropertyPlaybackDuration] = 36000
                        mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
                        mediaInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
                        if #available(iOS 10.0, *) {
                            mediaInfo[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
                        }
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
                        NSLog("\nShowed notification")
                    } catch {
                        print(error)
                    }
                }
            } catch {
                NSLog("\nFailed to start notification: %@", (error.localizedDescription))
                return
            }
            break;
        default:
            NSLog("\nInvalid notification type")
        // no-op
        }
        */
    }
}
