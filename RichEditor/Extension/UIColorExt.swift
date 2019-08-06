//
//  UIColorExt.swift
//  Record
//
//  Created by Maple on 2018/8/30.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import UIKit

extension UIColor {
//    convenience init(hexA: Int) {
//        self.init(red: ((CGFloat)((hexA & 0xFF000000) >> 24)) / 255.0,
//                  green: ((CGFloat)((hexA & 0xFF0000) >> 16)) / 255.0,
//                  blue: ((CGFloat)((hexA & 0xFF00) >> 8)) / 255.0,
//                  alpha: ((CGFloat)(hexA & 0xFF)) / 255.0)
//    }
    
    // 十六进制颜色
    static func hexColor(hex: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((hex & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(hex & 0xFF)) / 255.0,
                       alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0,
        green: ((CGFloat)((hex & 0xFF00) >> 8)) / 255.0,
        blue: ((CGFloat)(hex & 0xFF)) / 255.0,
        alpha: 1.0)
    }
}
