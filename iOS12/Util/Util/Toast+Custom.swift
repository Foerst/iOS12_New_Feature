//
//  Toast+Custom.swift
//  iOS12
//
//  Created by CXY on 2019/5/16.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit

extension Toast {
    static public func make(text: String) -> Toast {
        let toast = Toast(text: text)
        toast.view.bottomOffsetPortrait = (UIScreen.main.bounds.height-20)/2
        return toast
    }
}
