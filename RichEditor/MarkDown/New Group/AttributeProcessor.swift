//
//  AttributeProcessor.swift
//  RichEditor
//
//  Created by Maple on 2019/7/30.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

struct AttributesProcessor {
    weak var textView: MarkDownView?
    weak var style: MarkDownStyle?
    
    var attributes: [String: Any]? {
        if !markAttributes.isEmpty { return markAttributes }
        guard let textView = self.textView,
            let style = self.style,
            let textLayout = textView.textLayout,
            let attributedText = textView.attributedText else { return self.style?.normalStyle }
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
        return style.normalStyle
    }
    
    /// 手动设置 富文本样式
    var markAttributes: [String: Any]  = [ : ]
    
    init(textView: MarkDownView?, style: MarkDownStyle) {
        self.textView = textView
        self.style = style
    }
    
    // 文本处于的状态
    func element(range: NSRange) -> MarkDownElement? {
        guard let textView = self.textView,
            let textLayout = textView.textLayout else { return nil }
        let paragraphRange = (textView.text as NSString).paragraphRange(for: range)
        let prefixRange = NSRange(location: paragraphRange.location, length: 1)
        if let attachmentRanges = textLayout.attachmentRanges {
            var index: Int?
            for (i, value) in attachmentRanges.enumerated() {
                if let range = value as? NSRange, range == prefixRange {
                    index = i
                }
            }
            if index != nil,
                let attachment = textLayout.attachments?.element(at: index!),
                let content = attachment.content as? UIView {
                return findElement(at: content)
            }
        }
        return nil
    }
    
    
    
    /// 根据 item 设置 range 内的 文本属性
    func addAttributed(_ attributedString: NSMutableAttributedString,
                       at item: MarkDownItem,
                       in range: NSRange) {
        if let attributes = style?.attributes(with: item) {
            for attribute in attributes.enumerated() {
                attributedString.yy_setAttribute(attribute.element.key,
                                                 value: attribute.element.value,
                                                 range: range)
            }
        }
    }
    
    
    /// 持有自定义附件
    func findElement(at content: UIView) -> MarkDownElement? {
        guard let elements = textView?.elements else { return nil }
        for element in elements {
            if element.content == content {
                return element
            }
        }
        return nil
//        return textView?.elements.filter { $0.content == content }.first
    }
    
    /// 通过 附件 content 找到相对的 段落
    ///
    /// - Parameter content: 附件 内容
    /// - Returns: 段落  !!!!!!!   不包含 标记 content   !!!!!!
    func findElementRange(at content: UIView) -> NSRange? {
        var paragraphRange: NSRange?
        guard let attachments = textView?.textLayout?.attachments,
            let attachmentRanges = textView?.textLayout?.attachmentRanges else { return paragraphRange }
        // 附件的索引
        var index: Int?
        for (i, attachment) in attachments.enumerated() {
            if let temp = attachment.content as? UIButton,
                temp === content {
                index = i
            }
        }
        if index != nil,
            let tapRange = attachmentRanges.element(at: index!) as? NSRange {
            paragraphRange = (textView!.text as NSString).paragraphRange(for: tapRange)
            // 去掉 标记 content
            if let range = paragraphRange {
                paragraphRange = NSRange(location: range.location + 1, length: range.length - 1)
            }
            print("Find Element Paragraph Range: \(paragraphRange)")
        }
        return paragraphRange
    }
    
    /// 设置 range 内 mark dowm item 标记
    ///
    /// - Parameters:
    ///   - element: 标记 文本
    ///   - attributedString: 富文本
    ///   - item: 标记元素
    ///   - range: 所要 处理 文本的范围
    /// - Returns: 选中的范围
    func setElement(_ element: MarkDownElement,
                    with attributedString: NSMutableAttributedString,
                    at item: MarkDownItem,
                    in range: NSRange) -> NSRange? {
        let startRange = NSRange(location: range.location, length: 1)
        switch item {
        case .header1, .header2, .header3, .undone, .done, .unordered:
            var selectRange: NSRange?
            if let attachmentRanges = textView?.textLayout?.attachmentRanges,
                let attachments = textView?.textLayout?.attachments {
                if attachmentRanges.contains(startRange as NSValue) {  // 存在 mark down item 标记
                    var isSameItem: Bool = false  // 是否为同一标记
                    for (index, range) in attachmentRanges.enumerated() {
                        if range == (startRange as NSValue),
                            let content = attachments.element(at: index)?.content as? UIView,
                            let originItem = MarkDownItem(rawValue: content.tag) {
                            if originItem == item {
                                isSameItem = true
                            } else if (originItem == .undone || originItem == .done)
                                && (item == .undone || item == .done) {
                                isSameItem = true
                            }
                        }
                    }
                    if isSameItem {  // 同一 标记 移除属性 并 移除标记
                        selectRange = removeElement(with: attributedString, in: range)
                    } else {  // 不是 同一标记  重置
                        selectRange = replaceElement(with: attributedString, element: element, in: range)
                    }
                } else {
                    selectRange = addElement(with: attributedString, element: element, in: range)
                }
            } else {  // 不存在 直接标记
                selectRange = addElement(with: attributedString, element: element, in: range)
            }
            selectRange?.length = 0
            if let selectedRange = selectRange {
                textView?.selectedRange = selectedRange
            }
            return selectRange
        case .separator:
            guard let textView = textView else { return nil }
            let range = NSRange(location: textView.selectedRange.location + 3,
                                length: textView.selectedRange.length)
            attributedString.insert(element.attributedString!, at: textView.selectedRange.location)
            return range
        default:
            return nil
        }
    }
    
    /// 替换标记
    func replaceElement(with attributedString: NSMutableAttributedString,
                        element: MarkDownElement,
                        in range: NSRange) -> NSRange? {
        let selectRange = textView!.selectedRange
        let startRange = NSRange(location: range.location, length: 1)
        addAttributed(attributedString, at: element.item, in: range)
        attributedString.replaceCharacters(in: startRange, with: element.attributedString!)
        return selectRange
    }
    
    /// 添加标记
    func addElement(with attributedString: NSMutableAttributedString,
                    element: MarkDownElement,
                    in range: NSRange) -> NSRange? {
        var selectedRange: NSRange?
        if let textView = textView {
            selectedRange = NSRange(location: textView.selectedRange.location + 1,
                                  length: textView.selectedRange.length)
        }
        addAttributed(attributedString, at: element.item, in: range)
        attributedString.insert(element.attributedString!, at: range.location)
        return selectedRange
    }
    
    /// 移除 标记 返回 选中范围
    func removeElement(with attributedString: NSMutableAttributedString, in range: NSRange) -> NSRange {
        let startRange = NSRange(location: range.location, length: 1)
        let selectRange = NSRange(location: max(textView!.selectedRange.location - 1, 0),
                                  length: textView!.selectedRange.length)
        attributedString.yy_removeAttributes(in: range)
        style?.normalStyle.forEach {
            attributedString.yy_setAttribute($0.key, value: $0.value, range: range)
        }
        attributedString.replaceCharacters(in: startRange, with: NSAttributedString(string: ""))
        return selectRange
    }
}
