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
        var string = ""
        if let textLayout = textView.textLayout {
            // 不包含 控件 文本
            string = textLayout.text.string
            if let attachments = textLayout.attachments,
                let textRanges = textLayout.attachmentRanges {
                var offset: Int = 0
                for (index, attachment) in attachments.enumerated() {
                    if let element = element(at: attachment, elements: textView.elements),
                        var location = (textRanges.element(at: index) as? NSRange)?.location {
                        location += offset
                        string.insert(contentsOf: element.text, at: string.index(string.startIndex, offsetBy: location))
                        offset += element.text.count
                    }
                }
            }
            
        }
        if let attributedString = textView.attributedText,
            let font = style.attributes(with: .bold)?[.font] as? UIFont {
            attributedString.enumerateAttribute(.font, in: attributedString.yy_rangeOfAll(), options: []) { (result, range, stop) in
                if (result as? UIFont) == font {
                    print("\(range), \(attributedString.attributedSubstring(from: range).string)")
                }
            }
        }
        return string
    }
    
    /// 通过 YYTextAttachment 找到相对应的 元素信息
    static func element(at attachment: YYTextAttachment,
                        elements: [MarkDownElement]) -> MarkDownElement? {
        guard let content = attachment.content as? UIView else { return nil }
        return elements.filter { $0.content === content }.first
    }
}
