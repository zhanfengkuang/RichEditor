//
//  IntExt.swift
//  Record
//
//  Created by Maple on 2018/9/13.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import Foundation

let KB = 1024
let MB = 1024 * 1024
let GB = 1024 * 1024 * 1024
extension Int {
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var double: Double {
        return Double(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    var string: String {
        return String(self)
    }
    
    /// 整数位数
    ///
    /// - Parameter count: 正数位
    /// - Returns: In 转 String
    func format(_ count: Int = 2) -> String {
        return String(format: "%.0\(count)d", self)
    }
    
    /// 内存大小
    func bytes() -> String {
        let bytes: String
        if double < 0.1 * KB.double {
            bytes = double.format() + "B"
        } else if double < 0.1 * MB.double {
            bytes = (double / KB.double).format() + "K"
        } else if double < 0.1 * GB.double {
            bytes = (double / MB.double).format() + "M"
        } else {
            bytes = (double / GB.double).format() + "G"
        }
        return bytes
    }
    
    func quotientPlusOne(_ divisor: Int) -> Int {
        return self/divisor + (self%divisor > 0 ? 1 : 0)
    }
}
