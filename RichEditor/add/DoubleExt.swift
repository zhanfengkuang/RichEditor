//
//  DoubleExt.swift
//  Record
//
//  Created by Maple on 2018/9/5.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import Foundation

extension Double {
    /// 四舍五入输出Double
    ///
    /// - Parameter places: 小数点后保留几位
    /// - Returns: 结果值
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    /// 格式化输入字符串
    ///
    /// - Parameter count: 保留小点, 默认两位
    /// - Returns: 输入字符串
    func format(_ count: Int = 2) -> String {
        return String(format: "%.\(count)f", self)
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var int: Int {
        return Int(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    static var implicitDuration: Double = 0.25
}
