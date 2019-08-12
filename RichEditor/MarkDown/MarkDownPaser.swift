//
//  MarkDownPaser.swift
//  RichEditor
//
//  Created by Maple on 2019/8/2.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

class MarkDownParser: NSObject {
    let style: MarkDownStyle
    /// header
    var regexHeader: NSRegularExpression!
    /// underline
    var regexUnderline: NSRegularExpression!
    /// separator
    var regexSeparator: NSRegularExpression!
    /// bold
    var regexBold: NSRegularExpression!
    /// strikethrough
    var regexStrikethrough: NSRegularExpression!
    /// ordered unordered
    var regexList: NSRegularExpression!
    /// quote
    var regexQuote: NSRegularExpression!
    /// done
    var regexDone: NSRegularExpression!
    /// undone
    var regexUndone: NSRegularExpression!
    var elements: [MarkDownElement] = [ ]
    
    
    required init(style: MarkDownStyle) {
        self.style = style
        regexHeader = try! NSRegularExpression(pattern: "^((\\#{1,6}[^#].*)|(\\#{6}.+))$",
                                               options: .anchorsMatchLines)
        regexUnderline = try! NSRegularExpression(pattern: "(?<!_)__(?=[^ \\t_])(.+?)(?<=[^ \\t_])\\__(?!_)",
                                                  options: .anchorsMatchLines)
        regexSeparator = try! NSRegularExpression(pattern: "^[ \\t]*([*-])[ \\t]*((\\1)[ \\t]*){2,}[ \\t]*$",
                                                  options: .anchorsMatchLines)
        regexList = try! NSRegularExpression(pattern: "^[ \\t]*([*+-]|\\d+[.])[ \\t]+",
                                                  options: .anchorsMatchLines)
        regexQuote = try! NSRegularExpression(pattern: "^((\\>{1,6}[^>].*)|(\\>{6}.+))$",
                                              options: .anchorsMatchLines)
//        regexDone = try! NSRegularExpression(pattern: "^((\\- [ ]{1,6}[^- [ ]].*)|(\\- [ ]{6}.+))$",
//                                             options: .anchorsMatchLines)
//        regexUndone = try! NSRegularExpression(pattern: "", options: .anchorsMatchLines)
        regexBold = try! NSRegularExpression(pattern: "(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)",
                                             options: .init(rawValue: 0))
        regexStrikethrough = try! NSRegularExpression(pattern: "(?<!~)~~(?=[^ \\t~])(.+?)(?<=[^ \\t~])\\~~(?!~)",
                                                      options: .init(rawValue: 0))
    }
    
    func parseText(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.yy_setAttributes(style.normalStyle)
        
        // header 标题
        var headerOffset: Int = 0
        regexHeader.enumerateMatches(in: attributedString.string, options: .init(rawValue: 0), range: attributedString.yy_rangeOfAll()) { (result, flags, poniter) in
            if let resultRange = result?.range {
                print(resultRange)
                let location = resultRange.location + headerOffset
                let string = attributedString.attributedSubstring(from: NSRange(location: location,
                                                                                length: resultRange.length)).string
                var raw = prefixLengh(of: Character("#"), in: string)
                raw = min(raw, 3)
                guard let item = MarkDownItem(rawValue: raw + 55) else { return }
                print(item)
                style.attributes(with: item)?.forEach({ (key, value) in
                    attributedString.yy_setAttribute(key, value: value,
                                                     range: NSRange(location: location, length: resultRange.length))
                })
                guard let level = MarkDownHeader.Level(item) else { return }
                let header = MarkDownHeader(level: level, style: style)
                attributedString.replaceCharacters(in: NSRange(location: location, length: raw + 1),
                                                   with: header.attributedString!)
                
                elements.append(header)
                headerOffset -= raw
            }
        }
        
        // ordered   unordered
        var listOffset: Int = 0
        regexList.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
            if let range = result?.range {
                print("有序 无序: \(range)")
                
                let location = range.location + listOffset
                let list: MarkDownElement
                if range.length > 2 {  // 有序
                    let index = attributedString.attributedSubstring(from: NSRange(location: location, length: range.length)).string.dropLast(2).string.intValue
                    list = MarkDownOrdered(style: style, index: index ?? 1)
                } else {  // 无序
                    list = MarkDownUnordered(style: style)
                }
                attributedString.replaceCharacters(in: NSRange(location: location, length: range.length),
                                                   with: list.attributedString!)
                elements.append(list)
                listOffset = listOffset - range.length + 1
            }
        }
        
        // separator
        var separatorOffset: Int = 0
        regexSeparator.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
            if let range = result?.range {
                print("分割线: \(range)")
                let location = range.location + separatorOffset
                let separator = MarkDownSeparator(style: style, startLine: false, endLine: false)
                attributedString.replaceCharacters(in: NSRange(location: location, length: range.length),
                                                   with: separator.attributedString!)
                elements.append(separator)
                separatorOffset = separatorOffset - range.length + 1
            }
        }
        
        // Quote
        var quoteOffset: Int = 0
        regexQuote.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
            if let range = result?.range {
                let location = range.location + quoteOffset
                let string = attributedString.attributedSubstring(from: NSRange(location: location, length: range.length)).string
                let raw = prefixLengh(of: Character(">"), in: string)
                // > 为引用 >> 不算引用
                if raw > 1 { return }
                let quote = MarkDownQuote(style: style)
                style.attributes(with: .quote)?.forEach({ (key, value) in
                    attributedString.yy_setAttribute(key, value: value,
                                                     range: NSRange(location: location, length: range.length))
                })
                attributedString.replaceCharacters(in: NSRange(location: location, length: 2),
                                                   with: quote.attributedString!)
                elements.append(quote)
                quoteOffset -= 1
            }
        }
        
        // done
//        regexDone.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
//            if let range = result?.range {
//                var location = range.location + boldOffset
//                style.attributes(with: .bold)?.forEach({ (key, value) in
//                    attributedString.yy_setAttribute(key, value: value, range: range)
//                })
//                attributedString.deleteCharacters(in: NSRange(location: location, length: 2))
//                location -= 2
//                var lenght: Int = location + range.length
//                attributedString.deleteCharacters(in: NSRange(location: location - 2, length: ))
//            }
//        }
        
        //  !!!!!      underline  strikethrough bold  处理的顺序不能变   !!!!!
        // underline
        var underlineOffset: Int = 0
        regexUnderline.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
            if let range = result?.range {
                let location = range.location + underlineOffset
                style.attributes(with: .underline)?.forEach({ (key, value) in
                    attributedString.yy_setAttribute(key, value: value, range: NSRange(location: location, length: range.length))
                })
                let firstRange = NSRange(location: location, length: 2)
                attributedString.deleteCharacters(in: firstRange)
                let secondRange = NSRange(location: location - 4 + range.length, length: 2)
                attributedString.deleteCharacters(in: secondRange)
                underlineOffset -= 4
            }
        }
        
        // strikethrough
        var strikethroughOffset: Int = 0
        regexStrikethrough.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
            if let range = result?.range {
                let location = range.location + strikethroughOffset
                style.attributes(with: .strikethrough)?.forEach({ (key, value) in
                    attributedString.yy_setAttribute(key, value: value, range: NSRange(location: location, length: range.length))
                })
                let firstRange = NSRange(location: location, length: 2)
                attributedString.deleteCharacters(in: firstRange)
                let secondRange = NSRange(location: location - 4 + range.length, length: 2)
                attributedString.deleteCharacters(in: secondRange)
                strikethroughOffset -= 4
            }
        }
        
        // bold
        var boldOffset: Int = 0
        regexBold.enumerateMatches(in: attributedString.string, options: [], range: attributedString.yy_rangeOfAll()) { (result, flags, stop) in
            if let range = result?.range {
                let location = range.location + boldOffset
                style.attributes(with: .bold)?.forEach({ (key, value) in
                    attributedString.yy_setAttribute(key, value: value,
                                                     range: NSRange(location: location, length: range.length))
                })
                let firstRange = NSRange(location: location, length: 2)
                attributedString.deleteCharacters(in: firstRange)
                let secondRange = NSRange(location: location - 4 + range.length, length: 2)
                attributedString.deleteCharacters(in: secondRange)
                boldOffset -= 4
            }
        }
        
        return attributedString
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
    
    func prefixLengh(of char: Character, in string: String) -> Int {
        for (offset, c) in string.enumerated() {
            if c != char { return offset }
        }
        return string.count
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

extension Substring {
    var string: String {
        return String(self)
    }
}
