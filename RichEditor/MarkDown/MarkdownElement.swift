//
//  MarkdownElement.swift
//  RichEditor
//
//  Created by Maple on 2019/7/23.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

public enum MarkdownElement {
    /// 链接
    case link
    /// 图片
    case image
    /// todo
    case todo
    /// 标题
    case header1
    case header2
    case header3
    /// 中划线
    case strikeThroungh
    /// 斜体
    case italic
}

public protocol MarkdownItem {
    /// 编辑状态 所占的长度
    var count: Int { get }
    /// content 编辑器附件的内容
    var content: UIView? { set get }
}
extension MarkdownItem {
    var count: Int { return 1 }
}

public class MarkdownHeader: MarkdownItem {
    public var count: Int { return 1 }
    public var content: UIView?
    
    var index: Int = 0
    init() {
        index = 1
    }
}

//public class MarkdownImage: MarkdownItem {
//
//}
//
//public class MarkdownTodo: MarkdownItem {
//
//}
//
//public class MarkdownLinke: MarkdownItem {
//
//}


