//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by CXY on 2019/5/5.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import AVFoundation

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var titleLabel: UILabel?
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    private lazy var player: AVAudioPlayer? = {
        var player: AVAudioPlayer?
        do {
            let url = Bundle.main.url(forResource: "animation_bgm.mp3", withExtension: nil)!
            try player = AVAudioPlayer(contentsOf: url)
        } catch {
            print(error.localizedDescription)
        }
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: 通知弹窗下拉的时候调用
    func didReceive(_ notification: UNNotification) {
        
        titleLabel?.text = notification.request.content.title
        bodyLabel.text = notification.request.content.body
        // 文档上说调用该方法可以自动播放，实测6s上无效
        extensionContext?.mediaPlayingStarted()
        mediaPlay()
    }
    
    // The system draws a media button for you, handling all user interactions.
    var mediaPlayPauseButtonType: UNNotificationContentExtensionMediaPlayPauseButtonType {
        return .overlay
    }
    
    var mediaPlayPauseButtonFrame: CGRect {
        return CGRect(x: 0, y: 120, width: 50, height: 50)
    }
    
    // start playing your media file.
    func mediaPlay() {
        player?.play()
    }

    // stop playing your media file.
    func mediaPause() {
        player?.pause()
    }
    
    @IBAction func openApplication() {
        print("点击了注册")
    }
    
}
