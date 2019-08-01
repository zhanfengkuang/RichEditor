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
    
    init(attributes: Attributes = [ .header: MarkDownHeaderStyle() ]) {
        self.attributes = attributes
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 10
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
            
            let decoration = YYTextDecoration(style: .single, width: 1, color: .red)
            
            if strikethrough != nil {
                result[YYTextStrikethroughAttributeName] = decoration
                // MARK: 不知道 为啥 YYTextView 渲染不出来  NSAttributedString.Key.strikethroughColor
//                result[.strikethrough] = 2
//                result[.strikethroughColor] = UIColor.red
//                result[.baselineOffset] = 0
            }
            return result
        case .separator:
            return nil
            
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
    
    init(header1Font: UIFont = .boldSystemFont(ofSize: 17),
         header2Font: UIFont = .boldSystemFont(ofSize: 16),
         header3Font: UIFont = .boldSystemFont(ofSize: 15),
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
    
    init(doneFont: UIFont = UIFont.systemFont(ofSize: 15),
         doneColor: UIColor = UIColor(hex: 0xC4C4C4),
         undoneFont: UIFont = UIFont.systemFont(ofSize: 15),
         undoneColor: UIColor = UIColor(hex: 0x6D7278),
         size: CGSize = CGSize(width: 25, height: 17)) {
        self.doneFont = doneFont
        self.undoneFont = undoneFont
        self.doneColor = doneColor
        self.undoneColor = undoneColor
        self.size = size
    }
}

// MARK: - Separator
struct MarkDownSeparatorStyle {
    /// separator
    var color: UIColor
    var size: CGSize
    
    init(color: UIColor = UIColor(hex: 0xEEEEEE),
         size: CGSize = CGSize(width: screenWidth, height: 1)) {
        self.color = color
        self.size = size
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
}

