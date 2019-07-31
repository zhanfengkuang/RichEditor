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
    
    var paragraphStyle = NSParagraphStyle()
    /// 缩进
    var headIndent: CGFloat = 25
    
    
    
    init(attributes: Attributes = [ .header: MarkDownHeaderStyle() ]) {
        self.attributes = attributes
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
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.setParagraphStyle(paragraphStyle)
            paragraphStyle.headIndent = headIndent
            return [
                .font: font,
                .foregroundColor: elementStyle.color,
                .paragraphStyle: paragraphStyle
            ]
            
            
            
            var attributeds: [NSAttributedString.Key: Any] = [ : ]
        }
    }
}

public protocol MarkDownElementStyle {
    
}

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

extension MarkDownStyle.Key {
    /// 标题
    public static let header = MarkDownStyle.Key("mark_down_header")
    /// todo list
    public static let todo = MarkDownStyle.Key("mark_down_todo")
    /// image
    public static let image = MarkDownStyle.Key("mark_down_image")
    /// link
    public static let link = MarkDownStyle.Key("mark_down_link")
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
    static let underline: String = NSAttributedString.Key.underlineStyle.rawValue
    static let paragraphStyle: String = NSAttributedString.Key.paragraphStyle.rawValue
}

