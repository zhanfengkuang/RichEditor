//
//  MarkDownOptions.swift
//  RichEditor
//
//  Created by Maple on 2019/7/30.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

public class MarkDownStyle {
    typealias Attributes = [MarkDownStyle.Key: MarkDownElementStyle]
    
    var attributes: Attributes
    
    var paragraphStyle = NSMutableParagraphStyle()
    /// 缩进
    var headIndent: CGFloat = 25
    /// 文本字体
    var font: UIFont = UIFont.systemFont(ofSize: 15)
    /// 文本颜色
    var color: UIColor = UIColor(hex: 0x6D7278)
    private(set) var normalStyle: [String: Any] = [ : ]
    
    
    init(attributes: Attributes = [ : ]) {
        self.attributes = attributes
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 12
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 0
        let decoration = YYTextDecoration(style: .single, width: 0, color: .clear)
        normalStyle = [
            .foregroundColor: color,
            .font: font,
            .paragraphStyle: paragraphStyle,
            YYTextStrikethroughAttributeName: decoration,
            YYTextUnderlineAttributeName: decoration
        ]
    }
    
    public func attributes(with item: MarkDownItem) -> [String: Any]? {
        switch item {
        case .header1, .header2, .header3:
            let elementStyle = attributes[.header] as? MarkDownHeaderStyle ?? MarkDownHeaderStyle()
            let font: UIFont
            switch item {
            case .header1: font = elementStyle.header1Font
            case .header2: font = elementStyle.header2Font
            case .header3: font = elementStyle.header3Font
            default: font = self.font
            }
            paragraphStyle.headIndent = headIndent
            return [
                .font: font,
                .foregroundColor: elementStyle.color,
                .paragraphStyle: paragraphStyle
            ]
        case .done, .undone:
            let todoStyle = attributes[.todo] as? MarkDownTodoStyle ?? MarkDownTodoStyle()
            let font: UIFont
            let color: UIColor
            var strikethrough: NSUnderlineStyle?
            switch item {
            case .done:
                font = todoStyle.doneFont
                color = todoStyle.doneColor
                strikethrough = .single
            case .undone:
                font = todoStyle.undoneFont;
                color = todoStyle.undoneColor
            default:
                font = self.font;
                color = self.color
            }
            paragraphStyle.headIndent = headIndent
            
            var result: [String: Any] = [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
            ]
            
            let decoration = YYTextDecoration(style: .single, width: 1, color: todoStyle.strikethroughColor)
            
            if strikethrough != nil {
                result[YYTextStrikethroughAttributeName] = decoration
                // MARK: 不知道 为啥 YYTextView 渲染不出来  NSAttributedString.Key.strikethroughColor
//                result[.strikethrough] = 2
//                result[.strikethroughColor] = UIColor.red
//                result[.baselineOffset] = 0
            }
            return result
        case .unordered:
            let unorderedStyle = attributes[.unordered] as? MarkDownUnorderedStyle ?? MarkDownUnorderedStyle()
            paragraphStyle.headIndent = headIndent
            return [
                .font: unorderedStyle.font,
                .foregroundColor: unorderedStyle.color,
                .paragraphStyle: paragraphStyle,
            ]
        case .ordered:
            let orderedStyle = attributes[.ordered] as? MarkDownOrderedStyle ?? MarkDownOrderedStyle()
            paragraphStyle.headIndent = headIndent
            return [
                .font: orderedStyle.font,
                .foregroundColor: orderedStyle.color,
                .paragraphStyle: paragraphStyle
            ]
        case .quote:
            let quoteStyle = attributes[.quote] as? MarkDownQuoteStyle ?? MarkDownQuoteStyle()
            paragraphStyle.headIndent = headIndent
            return [
                .font: quoteStyle.font,
                .foregroundColor: quoteStyle.color,
                .paragraphStyle: paragraphStyle
            ]
        case .separator, .image:
            return normalStyle
        case .bold:
            let boldStyle = attributes[.bold] as? MarkDownBoldStyle ?? MarkDownBoldStyle()
            return [
                .foregroundColor: boldStyle.color,
                .font: boldStyle.font,
            ]
        case .highlighter:
            let highlightStyle = attributes[.highlight] as? MarkDownHighlighterStyle ?? MarkDownHighlighterStyle()
            return [
                .backgroundColor: highlightStyle.color
            ]
        case .italic:
            let italicStyle = attributes[.italic] as? MarkDownItalicStyle ?? MarkDownItalicStyle()
            return [
                .foregroundColor: italicStyle.color,
                .font: italicStyle.font,
            ]
        case .underline:
            let underlineStyle = attributes[.underline] as? MarkDownUnderlineStyle ?? MarkDownUnderlineStyle()
            let decoration = YYTextDecoration(style: .single, width: 1, color: underlineStyle.color)
            return [
                YYTextUnderlineAttributeName: decoration,
            ]
        case .strikethrough:
            let underlineStyle = attributes[.strikethrough] as? MarkDownStrikethroughStyle ?? MarkDownStrikethroughStyle()
            let decoration = YYTextDecoration(style: .single, width: 1, color: underlineStyle.color)
            return [
                YYTextStrikethroughAttributeName: decoration,
            ]
        }
    }
}

public protocol MarkDownElementStyle {
    
}

// MARK: - Header Style
public struct MarkDownHeaderStyle: MarkDownElementStyle {
    var header1Font: UIFont
    var header2Font: UIFont
    var header3Font: UIFont
    var color: UIColor
    var size: CGSize
    
    init(header1Font: UIFont = .boldSystemFont(ofSize: 18),
         header2Font: UIFont = .boldSystemFont(ofSize: 17),
         header3Font: UIFont = .boldSystemFont(ofSize: 16),
         color: UIColor = UIColor(hex: 0x6D7278),
         size: CGSize = CGSize(width: 25, height: 17)) {
        self.header1Font = header1Font
        self.header2Font = header2Font
        self.header3Font = header3Font
        self.color = color
        self.size = size
    }
}

// MARK: - TODO Style
struct MarkDownTodoStyle: MarkDownElementStyle {
    var doneFont: UIFont
    var doneColor: UIColor
    var undoneFont: UIFont
    var undoneColor: UIColor
    var size: CGSize
    /// 中滑 线 颜色
    var strikethroughColor: UIColor
    
    init(doneFont: UIFont = UIFont.systemFont(ofSize: 15),
         doneColor: UIColor = UIColor(hex: 0xC4C4C4),
         undoneFont: UIFont = UIFont.systemFont(ofSize: 15),
         undoneColor: UIColor = UIColor(hex: 0x6D7278),
         size: CGSize = CGSize(width: 25, height: 17),
         strikethroughColor: UIColor = UIColor(hex: 0xC4C4C4)) {
        self.doneFont = doneFont
        self.undoneFont = undoneFont
        self.doneColor = doneColor
        self.undoneColor = undoneColor
        self.size = size
        self.strikethroughColor = strikethroughColor
    }
}

// MARK: - Separator
struct MarkDownSeparatorStyle {
    /// separator color
    var color: UIColor
    var size: CGSize
    
    init(color: UIColor = UIColor(hex: 0xEEEEEE),
         size: CGSize = CGSize(width: screenWidth, height: 1)) {
        self.color = color
        self.size = size
    }
}

// MARK: - Unordered
struct MarkDownUnorderedStyle {
    /// 圆点 颜色
    var dotColor: UIColor
    /// 圆点 半径
    var dotRadius: CGFloat
    /// 文本 颜色
    var color: UIColor
    /// 控件大小
    var size: CGSize
    /// 文本 字体
    var font: UIFont
    
    init(dotColor: UIColor = UIColor(hex: 0xC5C7C9),
         dotRadius: CGFloat = 3,
         color: UIColor = UIColor(hex: 0x6D7278),
         size: CGSize = CGSize(width: 25, height: 16),
         font: UIFont = UIFont.systemFont(ofSize: 15)) {
        self.dotColor = dotColor
        self.dotRadius = dotRadius
        self.color = color
        self.size = size
        self.font = font
    }
}

// MARK: - Ordered
struct MarkDownOrderedStyle: MarkDownElementStyle {
    /// 有序 字体 颜色
    var titleColor: UIColor
    /// 有序 字体
    var titleFont: UIFont
    var size: CGSize
    var color: UIColor
    var font: UIFont
    
    init(titleColor: UIColor = UIColor(hex: 0xC5C7C9),
         titleFont: UIFont = UIFont.boldSystemFont(ofSize: 15),
         size: CGSize = CGSize(width: 25, height: 16),
         color: UIColor = UIColor(hex: 0x6D7278),
         font: UIFont = UIFont.systemFont(ofSize: 15)) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.size = size
        self.color = color
        self.font = font
    }
}

// MARK: - Quote
struct MarkDownQuoteStyle: MarkDownElementStyle {
    /// 引用 字体 颜色
    var titleColor: UIColor
    /// 引用 字体
    var titleFont: UIFont
    var size: CGSize
    var color: UIColor
    var font: UIFont
    
    init(titleColor: UIColor = UIColor(hex: 0xC4C4C4),
         titleFont: UIFont = UIFont.boldSystemFont(ofSize: 15),
         size: CGSize = CGSize(width: 25, height: 16),
         color: UIColor = UIColor(hex: 0xC4C4C4),
         font: UIFont = UIFont.systemFont(ofSize: 15)) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.size = size
        self.color = color
        self.font = font
    }
}

// MARK: - Image
struct MarkDownImageStyle: MarkDownElementStyle {
    /// 圆角 半径
    var radius: CGFloat
 
    init(radius: CGFloat = 8) {
        self.radius = radius
    }
}

// MARK: - Link
struct MarkDownLinkStyle: MarkDownElementStyle {
    
}

// MARK: - bold
struct MarkDownBoldStyle: MarkDownElementStyle {
    /// 字体
    var font: UIFont
    /// color
    var color: UIColor
    
    init(font: UIFont = UIFont.boldSystemFont(ofSize: 15),
         color: UIColor = UIColor(hex: 0x6D7278)) {
        self.font = font
        self.color = color
    }
}

// MARK: - highlighter
struct MarkDownHighlighterStyle: MarkDownElementStyle {
    /// color
    var color: UIColor
    
    init(color: UIColor = UIColor(hex: 0xDDFFB7)) {
        self.color = color
    }
}

// MARK: - italic
struct MarkDownItalicStyle: MarkDownElementStyle {
    /// color
    var color: UIColor
    /// font
    var font: UIFont
    
    init(color: UIColor = UIColor(hex: 0x6D7278),
         font: UIFont = UIFont.italicSystemFont(ofSize: 15)) {
        self.color = color
        self.font = font
    }
}

// MARK: - Underline
struct MarkDownUnderlineStyle: MarkDownElementStyle {
    /// color
    var color: UIColor
    init(color: UIColor = UIColor(hex: 0x6D7278)) {
        self.color = color
    }
}

// MARK: - Strikethrough
struct MarkDownStrikethroughStyle: MarkDownElementStyle {
    /// color
    /// color
    var color: UIColor
    init(color: UIColor = UIColor(hex: 0x6D7278)) {
        self.color = color
    }
}

extension MarkDownStyle.Key {
    /// 标题
    public static let header = MarkDownStyle.Key("mark_down_header")
    /// todo list
    public static let todo = MarkDownStyle.Key("mark_down_todo")
    /// image
    public static let image = MarkDownStyle.Key("mark_down_image")
    /// link
    public static let link = MarkDownStyle.Key("mark_down_link")
    /// separator
    public static let separator = MarkDownStyle.Key("mark_down_separator")
    /// 无序
    public static let unordered = MarkDownStyle.Key("mark_down_unordered")
    /// 有序
    public static let ordered = MarkDownStyle.Key("mark_down_ordered")
    /// 引用
    public static let quote = MarkDownStyle.Key("mark_down_quote")
    /// font
    public static let bold = MarkDownStyle.Key("mark_down_bold")
    /// highlight 荧光笔
    public static let highlight = MarkDownStyle.Key("mark_down_highlight")
    ///italic 斜体
    public static let italic = MarkDownStyle.Key("mark_down_italic")
    /// underline 下划线
    public static let underline = MarkDownStyle.Key("mark_down_underline")
    /// time 时间
    public static let time = MarkDownStyle.Key("mark_down_time")
    /// strikethrough 中划线
    public static let strikethrough = MarkDownStyle.Key("mark_down_strikethrough")
}

extension MarkDownStyle {
    public struct Key : Hashable, Equatable, RawRepresentable {
        public var rawValue: String
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension String {
    static let font: String = NSAttributedString.Key.font.rawValue
    static let foregroundColor: String = NSAttributedString.Key.foregroundColor.rawValue
    static let strikethrough: String = NSAttributedString.Key.strikethroughStyle.rawValue
    static let strikethroughColor: String = NSAttributedString.Key.strikethroughColor.rawValue
    static let underline: String = NSAttributedString.Key.underlineStyle.rawValue
    static let paragraphStyle: String = NSAttributedString.Key.paragraphStyle.rawValue
    static let baselineOffset: String = NSAttributedString.Key.baselineOffset.rawValue
    /// 背景色
    static let backgroundColor: String = NSAttributedString.Key.backgroundColor.rawValue
}

