//
//  NetworkViewController.swift
//  iOS12
//
//  Created by CXY on 2019/5/7.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {
    @IBOutlet weak var serviceLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Network Framework"
        
        NetworkManager.shared.detectServices { (list) in
            self.serviceLb.text = list.first?.type
        }
    }

    @IBAction func connectService() {
        NetworkManager.shared.connectService { (ret, error) in
            if ret {
                Toast.toast(text: "Connect Succeed!").show()
            } else {
                Toast.toast(text: error ?? "Connecting Failed!").show()
            }
        }
    }

    @IBAction func sendData() {
        if let data = UIImage(named: "attachment.png")?.pngData() {
            NetworkManager.shared.sendFrame(data)
        }
    }
    
    @IBAction func sendText() {
        let text = "hi".data(using: .utf8)!
        NetworkManager.shared.sendFrame(text)
    }
}
