//
//  AttributeProcessor.swift
//  RichEditor
//
//  Created by Maple on 2019/7/30.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

struct AttributesProcessor {
    weak var textView: YYTextView?
    weak var style: MarkDownStyle?
    
    var attributes: [String: Any]? {
        guard let textView = self.textView,
            let style = self.style,
            let textLayout = textView.textLayout,
            let attributedText = textView.attributedText else { return nil }
        let paragraph = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
        let text = NSMutableAttributedString(attributedString: attributedText)
        let prefixRange = NSRange(location: paragraph.location, length: 1)
        
        if let attachmentRanges = textLayout.attachmentRanges {
            var index: Int?
            for (i, value) in attachmentRanges.enumerated() {
                if let range = value as? NSRange, range == prefixRange {
                    index = i
                }
            }
            if index != nil,
            let attachment = textLayout.attachments?.element(at: index!),
            let tag = (attachment.content as? UIView)?.tag,
            let item = MarkDownItem(rawValue: tag) {
                return style.attributes(with: item)
            }
        }
        return nil
    }
    
    init(textView: YYTextView?, style: MarkDownStyle) {
        self.textView = textView
        self.style = style
    }
}
