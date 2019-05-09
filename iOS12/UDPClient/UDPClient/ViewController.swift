//
//  ViewController.swift
//  UDPClient
//
//  Created by CXY on 2019/5/7.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit
import Network

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceManager.shared.publishService { (ret) in
            if ret {
                let toast = Toast(text: "service publish succeed!")
                toast.view.bottomOffsetPortrait = (UIScreen.main.bounds.height-20)/2
                toast.show()
            } else {
                Toast(text: "service publish error!").show()
            }
            
        }
        ServiceManager.shared.onReceiveData = { data in
            if let text = String(data: data!, encoding: .utf8) {
                self.label.text = text
            }
            if let image = UIImage(data: data!) {
                self.image.image = image
            }
           
        }
    }
    

}

