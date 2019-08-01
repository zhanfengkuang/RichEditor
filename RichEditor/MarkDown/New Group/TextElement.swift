//
//  TextElement.swift
//  RichEditor
//
//  Created by Maple on 2019/7/11.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

//typealias RichText = (TextElementView) -> String
//typealias RichControl = (String) -> TextElementView

public enum MarkDownItem: Int {
    /// title
    case header1 = 56
    case header2 = 57
    case header3 = 58
    /// todo
    case done = 59
    case undone = 60
    /// 分割线
    case separator = 61
    /// 无序
    case unordered = 62
    /// 有序
    case ordered = 63
}

public protocol MarkDownElement {
    /// mark down 文本
    var text: String { get }
    /// mark down 文本样式
    var style: MarkDownStyle { set get }
    /// 控件富文本
    var attributedString: NSMutableAttributedString? { set get }
}

// MARK: - Header
class MarkDownHeader: MarkDownElement {
    enum Level: Int {
        case header1 = 56
        case header2 = 57
        case header3 = 58
        
        var text: String {
            switch self {
            case .header1: return "# "
            case .header2: return "## "
            case .header3: return "### "
            }
        }
        
        var image: UIImage {
            switch self {
            case .header1: return #imageLiteral(resourceName: "editor_toolbar_header1_normal")
            case .header2: return #imageLiteral(resourceName: "editor_toolbar_header2_normal")
            case .header3: return #imageLiteral(resourceName: "editor_toolbar_header3_normal")
            }
        }
    }
    
    var style: MarkDownStyle
    var headerStyle: MarkDownHeaderStyle
    
    var text: String {
        return level.text
    }
    
    var level: Level
    
    var attributedString: NSMutableAttributedString?
    
    init(level: Level, style: MarkDownStyle) {
        self.level = level
        self.style = style
        self.headerStyle = (style.attributes[.header] as? MarkDownHeaderStyle) ?? MarkDownHeaderStyle()
        let headerView = UIImageView()
        headerView.image = level.image
        headerView.contentMode = .left
        headerView.jr_size = headerStyle.size
        headerView.tag = level.rawValue
        
        attributedString = NSMutableAttributedString(string: "\n")
        let string = NSMutableAttributedString.yy_attachmentString(withContent: headerView,
                                                                   contentMode: .center,
                                                                   attachmentSize: headerStyle.size,
                                                                   alignTo: .systemFont(ofSize: 15),
                                                                   alignment: .top)
        attributedString?.append(string)
    }
}

// MARK: - TODO List
class MarkDownTodo: MarkDownElement {
    enum State: Int {
        case done = 59
        case undone = 60
        
        var text: String {
            switch self {
            case .done: return "- [ ] "
            case .undone: return "- [x] "
            }
        }
    }
    var text: String { return state.text }
    // 完成状态
    var state: State = .undone
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    
    var tapBlock: ((UIButton) -> Void)?
    
    init(style: MarkDownStyle, state: State) {
        self.style = style
        self.state = state
        let todoStyle = style.attributes[.todo] as? MarkDownTodoStyle ?? MarkDownTodoStyle()
        
        
        
        let todoBtn = UIButton(type: .custom)
        todoBtn.isSelected = state == .done
        todoBtn.setImage(UIImage(named: "rich_text_todo_done"), for: .selected)
        todoBtn.setImage(UIImage(named: "rich_text_todo_undone"), for: .normal)
        todoBtn.contentHorizontalAlignment = .left
        todoBtn.tag = state.rawValue
        todoBtn.imageView?.contentMode = .left
        todoBtn.jr_size = todoStyle.size
        todoBtn.addTarget(self, action: #selector(changeSate(_:)), for: .touchUpInside)
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: todoBtn,
                                                                         contentMode: .left,
                                                                         attachmentSize: todoStyle.size,
                                                                         alignTo: style.font,
                                                                         alignment: .center)
        
    }
    
    // action
    @objc func changeSate(_ sender: UIButton) {
        sender.isSelected.toggle()
        state = sender.isSelected ? .done : .undone
        sender.tag = state.rawValue
        tapBlock?(sender)
    }
}

// MARK: - Separator
class MarkDownSeparator: MarkDownElement {
    var text: String { return "----" }
    var attributedString: NSMutableAttributedString?
    var style: MarkDownStyle
    
    required init(style: MarkDownStyle) {
        self.style = style
        let separatorStyle = style.attributes[.separator] as? MarkDownSeparatorStyle ?? MarkDownSeparatorStyle()
        
        let separator = UIView()
        separator.tag = MarkDownItem.separator.rawValue
        separator.backgroundColor = separatorStyle.color
        separator.size = separatorStyle.size
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: separator,
                                                                         contentMode: .center,
                                                                         attachmentSize: separatorStyle.size,
                                                                         alignTo: .systemFont(ofSize: 15),
                                                                         alignment: .top)
    }
}

// MARK: - Ordered
class MarkDownOrdered: MarkDownElement {
    var text: String { return "" }
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    
    required init(style: MarkDownStyle) {
        self.style = style
//        let orderedStyle = style.attributes[.ordered] as? MarkDown
    }
}

class MarkDownUnordered: MarkDownElement {
    var text: String { return "* " }
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    
    required init(style: MarkDownStyle) {
        self.style = style
        let unorderedStyle = style.attributes[.unordered] as? MarkDownUnorderedStyle ?? MarkDownUnorderedStyle()
        // unordered view
        let unordered = UIView()
        unordered.jr_size = unorderedStyle.size
        unordered.tag = MarkDownItem.unordered.rawValue
        // dot
        let dot = UIView()
        let radius = unorderedStyle.dotRadius
        dot.jr_size = CGSize(width: radius*2, height: radius*2)
        dot.center = unordered.center
        dot.layer.cornerRadius = unorderedStyle.dotRadius
        dot.backgroundColor = unorderedStyle.dotColor
        unordered.addSubview(dot)
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: unordered,
                                                                         contentMode: .left,
                                                                         attachmentSize: unorderedStyle.size,
                                                                         alignTo: .systemFont(ofSize: 15),
                                                                         alignment: .center)
    }
}
