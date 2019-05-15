//
//  ShortcutsViewController.swift
//  iOS12
//
//  Created by CXY on 2019/5/13.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit
import CoreSpotlight
import Intents
import IntentsUI

public let activityType = "com.ubt.ios12.useractivity"

class ShortcutsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Siri Shortcuts"
        
        // 1. NSUserActivity shortcuts
        
        let userActivityShortcuts = {
            self.defineUserActivityShortcuts()
            self.donateUserActivityShortcuts()
            self.handleUserActivityShortcuts()
        }
        userActivityShortcuts()
        
        // 2. Intent shortcuts
        
        let _  = {
            self.defineIntentsShortcuts()
            self.donateIntentsShortcuts()
            self.handleIntentsShortcuts()
        }
//        intentsShortcuts()
        
        INPreferences.requestSiriAuthorization { (status) in
            switch status {
            case .authorized:
                print("authorized")
            default:
                break
            }
        }
        
    }
    
    // MARK: NSUserActivity
    
    private func defineUserActivityShortcuts() {
        // add key in your info.plist file
    }
    
    private func donateUserActivityShortcuts() {
        let userActivity = NSUserActivity(activityType: activityType)
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.title = "Activity"
        userActivity.userInfo = ["key": "value"]
        
        self.userActivity = userActivity
    }
    
    private func handleUserActivityShortcuts() {
        
    }
    
    // MARK: Intents
    
    private func defineIntentsShortcuts() {
        // in Intents.intentdefinition file
    }
    
    private func donateIntentsShortcuts() {
        
        let interaction = INInteraction(intent: orderSoupIntent, response: nil)
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: \(error.localizedDescription)")
                }
            } else {
                print("Successfully donated interaction")
            }
        }
        
        // 录制Siri短语
        
        present(voiceVC, animated: true, completion: nil)
        
    }
    
    private func handleIntentsShortcuts() {
//        OrderSoupIntent
//        OrderSoupIntentResponse
    }

    
    @IBAction func addIntentToSiri() {
        // 请求授权使用Siri
        
        if INPreferences.siriAuthorizationStatus() != .authorized {
            let alert = UIAlertController(title: "Error", message: "Siri Access unAuthorization!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        donateIntentsShortcuts()
    }
    
    // MARK: Lazy Load
    
    private lazy var orderSoupIntent: OrderSoupIntent = {
        let orderSoupIntent = OrderSoupIntent()
        orderSoupIntent.quantity = 2
        orderSoupIntent.soup = "海带汤"
        //可以设置图片，显示在shortcuts列表上
        orderSoupIntent.setImage(INImage(named: "Soup.png"), forParameterNamed: \OrderSoupIntent.image)
        // siri 触发调用短语
        orderSoupIntent.suggestedInvocationPhrase = "点汤"
        
        return orderSoupIntent
    }()
    
    private lazy var voiceVC: INUIAddVoiceShortcutViewController = {
        let shortcut = INShortcut(intent: orderSoupIntent)!
        let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        vc.delegate = self
        return vc
    }()
    
}



extension ShortcutsViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension ShortcutsViewController: OrderSoupIntentHandling {
    
    func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        let response = OrderSoupIntentResponse.success(soup: intent.soup ?? "")
        completion(response)
    }
    
    func confirm(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Swift.Void) {
        let response = OrderSoupIntentResponse.success(soup: intent.soup ?? "")
        completion(response)
    }
}


