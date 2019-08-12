//
//  MarkDownTransform.swift
//  RichEditor
//
//  Created by Maple on 2019/8/2.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

struct MarkDownTransform {
    
    static func text(at textView: MarkDownTextView, style: MarkDownStyle) -> String {
        let attributedString = NSMutableAttributedString(string: "")
        if let textLayout = textView.textLayout,
            let text = textView.attributedText {
            attributedString.append(text)
            if let attachments = textLayout.attachments,
                let textRanges = textLayout.attachmentRanges {
                var offset: Int = 0
                for (index, attachment) in attachments.enumerated() {
                    if let element = element(at: attachment, elements: textView.elements),
                        var attachmentRange = (textRanges.element(at: index) as? NSRange) {
                        attachmentRange.location += offset
                        attributedString.replaceCharacters(in: attachmentRange, with: element.text)
                        offset += element.text.count - 1
                    }
                }
            }
            
            // blod
            var boldRanges: [NSRange] = [ ]
            attributedString.enumerateAttribute(.font, in: attributedString.yy_rangeOfAll(), options: []) { (result, range, stop) in
                if let font = style.attributes(with: .bold)?[.font] as? UIFont,
                    let resultFont = result as? UIFont,
                    font.fontName == resultFont.fontName,
                    font.familyName == resultFont.familyName,
                    font.pointSize == resultFont.pointSize {
                    print("blod attributed string: \(attributedString.attributedSubstring(from: range)), range: \(range)")
//                    let strings = attributedString.string.split(separator: "\n")
                    if var lastRange = boldRanges.last,
                        lastRange.location + lastRange.length == range.location {
                        lastRange.length += range.length
                        boldRanges.replaceSubrange((boldRanges.count-1..<boldRanges.count),
                                                            with: [lastRange])
                    } else {
                        boldRanges.append(range)
                    }
                }
            }
            var boldOffset: Int = 0
            boldRanges.forEach { (range) in
                let firstRange = NSRange(location: range.location + boldOffset, length: 0)
                let markString = NSMutableAttributedString(string: "**")
                style.normalStyle.forEach({ (key, value) in
                    markString.yy_setAttribute(key, value: value, range: markString.yy_rangeOfAll())
                })
                attributedString.replaceCharacters(in: firstRange, with: markString)
                let subString = attributedString.attributedSubstring(from: NSRange(location: range.location + boldOffset + 2,
                                                                                   length: range.length))
                // 去掉换行
                let length = suffixLine(subString.string) ? 1 : 2
                let secondRange = NSRange(location: range.location + range.length + length + boldOffset , length: 0)
                attributedString.replaceCharacters(in: secondRange, with: markString)
                boldOffset += 4
            }
            
            // strikethrough 中划线
            var strikethroughRanges: [NSRange] = [ ]
            attributedString.enumerateAttributes(in: attributedString.yy_rangeOfAll(), options: [ ]) { (result, range, top) in
                result.forEach({ (key, value) in
                    if key.rawValue == YYTextStrikethroughAttributeName,
                        let decoration = value as? YYTextDecoration,
                        let color = decoration.color, color != .clear,
                        let width = decoration.width?.intValue, width > 0 {
                        if var lastRange = strikethroughRanges.last,
                            lastRange.location + lastRange.length == range.location {
                            lastRange.length += range.length
                            strikethroughRanges.replaceSubrange((strikethroughRanges.count-1..<strikethroughRanges.count),
                                                                with: [lastRange])
                        } else {
                            strikethroughRanges.append(range)
                        }
                    }
                })
            }
            var strikethroughOffset: Int = 0
            strikethroughRanges.forEach { (range) in
                let firstRange = NSRange(location: range.location + strikethroughOffset, length: 0)
                let markString = NSMutableAttributedString(string: "~~")
                style.normalStyle.forEach({ (key, value) in
                    markString.yy_setAttribute(key, value: value, range: markString.yy_rangeOfAll())
                })
                attributedString.replaceCharacters(in: firstRange, with: markString)
                let subString = attributedString.attributedSubstring(from: NSRange(location: range.location + strikethroughOffset + 2,
                                                                                   length: range.length))
                let length = suffixLine(subString.string) ? 1 : 2
                let secondRange = NSRange(location: range.location + range.length + length + strikethroughOffset, length: 0)
                attributedString.replaceCharacters(in: secondRange, with: markString)
                strikethroughOffset += 4
            }
            
            // underline 下划线
            var underlineRanges: [NSRange] = [ ]
            attributedString.enumerateAttributes(in: attributedString.yy_rangeOfAll(), options: []) { (result, range, top) in
                result.forEach({ (key, value) in
                    if key.rawValue == YYTextUnderlineAttributeName,
                        let decoration = value as? YYTextDecoration,
                        let color = decoration.color, color != .clear,
                        let width = decoration.width?.intValue, width > 0 {
                        if var lastRange = underlineRanges.last,
                            lastRange.location + lastRange.length == range.location {
                            lastRange.length += range.length
                            underlineRanges.replaceSubrange((underlineRanges.count-1..<underlineRanges.count),
                                                                with: [lastRange])
                        } else {
                            underlineRanges.append(range)
                        }
                    }
                })
            }
            var underlineOffset: Int = 0
            underlineRanges.forEach { (range) in
                let firstRange = NSRange(location: range.location + underlineOffset, length: 0)
                let markString = NSMutableAttributedString(string: "__")
                style.normalStyle.forEach({ (key, value) in
                    markString.yy_setAttribute(key, value: value, range: markString.yy_rangeOfAll())
                })
                attributedString.replaceCharacters(in: firstRange, with: markString)
                let subString = attributedString.attributedSubstring(from: NSRange(location: range.location + underlineOffset + 2, length: range.length))
                let length = suffixLine(subString.string) ? 1 : 2
                let secondRange = NSRange(location: range.location + range.length + length + underlineOffset, length: 0)
                attributedString.replaceCharacters(in: secondRange, with: markString)
                underlineOffset += 4
            }
            
            // 高亮
            var highlighterRanges: [NSRange] = [ ]
            attributedString.enumerateAttributes(in: attributedString.yy_rangeOfAll(), options: []) { (result, range, top) in
                result.forEach({ (key, value) in
                    if key == .backgroundColor {
                        if var lastRange = highlighterRanges.last,
                            lastRange.location + lastRange.length == range.location {
                            lastRange.length += range.length
                            highlighterRanges.replaceSubrange((highlighterRanges.count-1..<highlighterRanges.count),
                                                            with: [lastRange])
                        } else {
                            highlighterRanges.append(range)
                        }
                    }
                })
            }
            var highlighOffset: Int = 0
            highlighterRanges.forEach { (range) in
                let firstRange = NSRange(location: range.location + highlighOffset, length: 0)
                let markString = NSMutableAttributedString(string: "::")
                style.normalStyle.forEach({ (key, value) in
                    markString.yy_setAttribute(key, value: value, range: markString.yy_rangeOfAll())
                })
                attributedString.replaceCharacters(in: firstRange, with: markString)
                let secondRange = NSRange(location: range.location + range.length + 2 + highlighOffset, length: 0)
                attributedString.replaceCharacters(in: secondRange, with: markString)
                highlighOffset += 4
            }
            
        }
        print("mark down string: \(attributedString.string)")
        return attributedString.string
    }
    
//    static func lengthOfEnd(in string: String, with range: NSRange) -> Int {
//
//    }
    
    // 是否为标记符
    static func isMark(_ string: String) -> Bool {
        return string == "__"
            || string == "~~"
            || string == "**"
    }
    
    /// 换行结尾
    static func suffixLine(_ string: String) -> Bool {
        return string.hasSuffix("\n")
            || string.hasSuffix("\t")
            || string.hasSuffix("\r")
    }
    
    /// 通过 YYTextAttachment 找到相对应的 元素信息
    static func element(at attachment: YYTextAttachment,
                        elements: [MarkDownElement]) -> MarkDownElement? {
        guard let content = attachment.content as? UIView else { return nil }
        return elements.filter { $0.content === content }.first
    }
}
