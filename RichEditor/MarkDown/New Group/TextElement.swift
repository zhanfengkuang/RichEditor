//
//  TextElement.swift
//  RichEditor
//
//  Created by Maple on 2019/7/11.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

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
    /// 图片
    case image = 64
    /// 黑体
    case bold = 65
    /// 斜体
    case italic = 66
    /// 中划线
    case strikethrough = 67
    /// 下滑线
    case underline = 68
    /// 荧光笔
    case highlighter = 69
    /// 引用
    case quote = 70
//    /// 时间
//    case time = 71
}

public protocol MarkDownElement {
    /// mark down 文本
    var text: String { get }
    /// mark down 文本样式
    var style: MarkDownStyle { set get }
    /// 控件富文本
    var attributedString: NSMutableAttributedString? { set get }
    /// content
    var content: UIView? { get }
    /// item
    var item: MarkDownItem { get }
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
        
        init?(_ item: MarkDownItem) {
            guard let level = Level(rawValue: item.rawValue) else { return nil }
            self = level
        }
    }
    
    var item: MarkDownItem { return MarkDownItem(rawValue: level.rawValue) ?? .header1 }
    var style: MarkDownStyle
    var headerStyle: MarkDownHeaderStyle
    var content: UIView? { return header }
    
    private var header: UIView!
    
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
        self.header = headerView
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: headerView,
                                                                   contentMode: .center,
                                                                   attachmentSize: headerStyle.size,
                                                                   alignTo: .systemFont(ofSize: 15),
                                                                   alignment: .top)
    }
}

// MARK: - TODO List
class MarkDownTodo: MarkDownElement {
    enum State: Int {
        case done = 59
        case undone = 60
        
        var text: String {
            switch self {
            case .done: return "- [x] "
            case .undone: return "- [ ] "
            }
        }
    }
    var item: MarkDownItem { return state == .undone ? .undone : .done  }
    var text: String { return state.text }
    // 完成状态
    var state: State = .undone
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    var content: UIView? { return todo }
    
    private var todo: UIView!
    
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
        self.todo = todoBtn
        
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
    var item: MarkDownItem { return .separator }
    var text: String { return "----" }
    var attributedString: NSMutableAttributedString?
    var style: MarkDownStyle
    var content: UIView? { return separator }
    
    private var separator: UIView!
    
    required init(style: MarkDownStyle) {
        self.style = style
        let separatorStyle = style.attributes[.separator] as? MarkDownSeparatorStyle ?? MarkDownSeparatorStyle()
        
        separator = UIView()
        separator.tag = MarkDownItem.separator.rawValue
        separator.backgroundColor = separatorStyle.color
        separator.size = separatorStyle.size
        attributedString = NSMutableAttributedString(string: "\n")
        let string = NSMutableAttributedString.yy_attachmentString(withContent: separator,
                                                                         contentMode: .center,
                                                                         attachmentSize: separatorStyle.size,
                                                                         alignTo: .systemFont(ofSize: 15),
                                                                         alignment: .top)
        string.append(NSAttributedString(string: "\n"))
        attributedString?.append(string)
    }
}

// MARK: - Ordered
class MarkDownOrdered: MarkDownElement {
    var item: MarkDownItem { return .ordered }
    var text: String { return "\(index). " }
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    var index: Int
    
    var content: UIView? { return ordered }
    private var ordered: UIView!
    
    required init(style: MarkDownStyle, index: Int) {
        self.style = style
        self.index = index
        let orderedStyle = style.attributes[.ordered] as? MarkDownOrderedStyle ?? MarkDownOrderedStyle()
        let ordered = UILabel()
        ordered.font = orderedStyle.titleFont
        ordered.textColor = orderedStyle.titleColor
        ordered.text = "\(index)."
        ordered.jr_size = orderedStyle.size
        ordered.textAlignment = .left
        ordered.tag = MarkDownItem.ordered.rawValue
        self.ordered = ordered
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: ordered,
                                                                         contentMode: .center,
                                                                         attachmentSize: orderedStyle.size,
                                                                         alignTo: .systemFont(ofSize: 15),
                                                                         alignment: .center)
    }
}

class MarkDownUnordered: MarkDownElement {
    var item: MarkDownItem { return .unordered }
    var text: String { return "* " }
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    
    var content: UIView? { return unordered }
    private var unordered: UIView!
    
    required init(style: MarkDownStyle) {
        self.style = style
        let unorderedStyle = style.attributes[.unordered] as? MarkDownUnorderedStyle ?? MarkDownUnorderedStyle()
        // unordered view
        unordered = UIView()
        unordered.jr_size = unorderedStyle.size
        unordered.tag = MarkDownItem.unordered.rawValue
        // dot
        let dot = UIView()
        let radius = unorderedStyle.dotRadius
        dot.jr_size = CGSize(width: radius*2, height: radius*2)
        dot.center = CGPoint(x: radius, y: unordered.center.y)
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

// MARK: - Image
class MarkDownImage: MarkDownElement {
    var content: UIView?

    var text: String { return "" }
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    var item: MarkDownItem { return .image }
    var url: String?
    
    var tapBlock: ((UIButton) -> Void)?

    required init(style: MarkDownStyle, size: CGSize, image: UIImage) {
        self.style = style
        let imageStyle = style.attributes[.image] as? MarkDownImageStyle ?? MarkDownImageStyle()

        let imageView = UIButton(type: .custom)
        imageView.imageView?.contentMode = .scaleAspectFill
        imageView.setImage(image, for: .normal)
        imageView.size = size
        imageView.layer.cornerRadius = imageStyle.radius
        imageView.layer.masksToBounds = true
        imageView.addTarget(self, action: #selector(selectImage(_:)), for: .touchUpInside)
        imageView.tag = item.rawValue
        content = imageView
        
        attributedString = NSMutableAttributedString(string: "\n")
        let string = NSMutableAttributedString.yy_attachmentString(withContent: imageView,
                                                                   contentMode: .center,
                                                                   attachmentSize: size,
                                                                   alignTo: .systemFont(ofSize: 15),
                                                                   alignment: .center)
        string.append(NSAttributedString(string: "\n"))
        attributedString?.append(string)
    }
    
    @objc func selectImage(_ sender: UIButton) {
        tapBlock?(sender)
    }
}

// MARK: - Quote 引用
class MarkDownQuote: MarkDownElement {
    var text: String { return "> " }
    var style: MarkDownStyle
    var attributedString: NSMutableAttributedString?
    var content: UIView? { return quote }
    var item: MarkDownItem { return .quote }
    
    private let quote: UILabel
    
    required init(style: MarkDownStyle) {
        self.style = style
        let quoteStyle = style.attributes[.quote] as? MarkDownQuoteStyle ?? MarkDownQuoteStyle()
        quote = UILabel()
        quote.font = quoteStyle.titleFont
        quote.textColor = quoteStyle.titleColor
        quote.text = text
        quote.jr_size = quoteStyle.size
        quote.textAlignment = .left
        quote.tag = item.rawValue
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: quote,
                                                                         contentMode: .center,
                                                                         attachmentSize: quoteStyle.size,
                                                                         alignTo: .systemFont(ofSize: 15),
                                                                         alignment: .center)
    }
    
    
}
