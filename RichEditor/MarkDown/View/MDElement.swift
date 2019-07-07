//
//  MDElement.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/20.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

enum MDElementType {
    case bold
    case h1
    case h2
    case h3
    case italic
    case strikeThroungh
    
    var regexString: String {
        switch self {
        case .bold:
            return "((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))"
        case .h1:
            return ""
        case .h2:
            return ""
        case .h3:
            return ""
        case .italic:
            return ""
        case .strikeThroungh:
            return ""
        }
    }
    
    var regex: NSRegularExpression? {
        switch self {
        case .bold:
            return try? NSRegularExpression(pattern: regexString, options: .init())
        default:
            return try? NSRegularExpression(pattern: regexString, options: .anchorsMatchLines)
        }
    }
}

protocol MDElement {
    var type: MDElementType { get }
    
}
