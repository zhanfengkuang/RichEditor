//
//  MDControl.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/18.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

public enum MDControlType: Int, CaseIterable {
    case task = 56
    case line
    case image
    
    // 控件的长度
    var count: Int {
        switch self {
        case .task:
            return 1
        case .line:
            return 1
        case .image:
            return 1
        }
    }
    
    var content: MDControl.Type {
        switch self {
        case .task:
            return MDTaskList.self
        case .line:
            return MDLine.self
        case .image:
            return MDImage.self
        }
    }
}

public protocol MDControl {
    var attributedString: NSMutableAttributedString? { set get }
    /// 控件类型
    var type: MDControlType { get }
    /// 转为 md 字符串
    var md: String { get }
}


