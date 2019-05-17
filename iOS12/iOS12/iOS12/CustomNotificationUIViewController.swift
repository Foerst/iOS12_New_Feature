//
//  NotificationViewController.swift
//  iOS12
//
//  Created by CXY on 2019/5/5.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit
import UserNotifications

class CustomNotificationUIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Notification"
    }
    
    private func presentLocalNotification(isNew: Bool = false) {
        if #available(iOS 10.0, *) {
            
            // 1.设置触发条件
            let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            // 2.创建通知内容
            let content = UNMutableNotificationContent()
            content.title = "PLANE AVAILABLE"
            //            content.subtitle = "This is subtitle"
            content.body = "The plane you requested will be fueled and ready at 1pm."
            content.badge = NSNumber(value:(UIApplication.shared.applicationIconBadgeNumber + 1))
            content.sound = UNNotificationSound.default
            do {
                
                let attachment = try UNNotificationAttachment(identifier: "banner.picture", url: Bundle.main.url(forResource: "attachment", withExtension: "png")!, options: nil)
                content.attachments = [attachment]
            } catch {
                print(error.localizedDescription)
            }
           
            // 设置categoryIdentifier， 下拉通知才能显示新的自定义UI
            if isNew {
               content.categoryIdentifier = "PLANE_AVAILABLE"
            }
            
            let detail = "detail"
            let userInfo = ["detail": detail]
            content.userInfo = userInfo
            // 3.通知标识
            let requestIdentifier = String(format: "%lf", NSDate().timeIntervalSince1970)
            // 4.创建通知请求，将1，2，3添加到请求中
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: timeTrigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error == nil {
                    print("推送成功")
                }
            })
            
        } else {
            let notification = UILocalNotification()
            notification.alertBody = "The plane you requested will be fueled and ready at 1pm."
            notification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            notification.soundName = UILocalNotificationDefaultSoundName
            let detail = "推送详情"
            let userInfo = ["detail": detail]
            notification.userInfo = userInfo
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now()+5.0) {
                UIApplication.shared.presentLocalNotificationNow(notification)
            }
        }
    }

    @IBAction func oldNotif() {
        presentLocalNotification()
    }
    
    @IBAction func newCustomNotif() {
        presentLocalNotification(isNew: true)
    }
    

}
