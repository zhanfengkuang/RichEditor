//
//  MarkDownPaser.swift
//  RichEditor
//
//  Created by Maple on 2019/8/2.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

class MarkDownParse: NSObject {
    let style: MarkDownStyle
    /// header
    var regexHeader: NSRegularExpression!
    var elements: [MarkDownElement] = [ ]
    
    
    required init(style: MarkDownStyle) {
        self.style = style
        regexHeader = try! NSRegularExpression(pattern: "^((\\#{1,6}[^#].*)|(\\#{6}.+))$", options: .anchorsMatchLines)
    }
    
    func parseText(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        return attributedString
    }
    
    func parseText(_ text: NSMutableAttributedString?,
                   selectedRange: NSRangePointer?) -> Bool {
        guard let text = text, text.length > 0 else { return false }
        text.yy_font = style.font
        text.yy_color = style.color
        
        regexHeader.enumerateMatches(in: text.string,
                                     options: .init(rawValue: 0),
                                     range: text.yy_rangeOfAll()) { [weak self] (result, flags, poniter) in
                                        guard let weakSelf = self else { return }
                                        if let resultRange = result?.range {
                                            let header = MarkDownHeader(level: .header1, style: weakSelf.style)
                                            weakSelf.setAttributes(text, item: .header1, range: NSRange(location: 0, length: 2))
                                            text.replaceCharacters(in: NSRange(location: 0, length: 2),
                                                                   with: header.attributedString!)
                                            weakSelf.elements.append(header)
                                        }
        }
        
        return true
    }
    
    func setAttributes(_ attributedString: NSMutableAttributedString,
                       item: MarkDownItem,
                       range: NSRange) {
        if let attributes = style.attributes(with: item) { // 设置该段落的字体属性
            for attribute in attributes.enumerated() {
                attributedString.yy_setAttribute(attribute.element.key,
                                                 value: attribute.element.value,
                                                 range: range)
            }
        }
    }
    
    func lenghOfBeginWhite(in string: String, with range: NSRange) -> Int {
        for index in 0..<range.length {
            let char = String((string as NSString).character(at: index + range.location))
            if char != " "
                && char != "\t"
                && char != "\n" {
                return index
            }
        }
        return string.count
    }
}
