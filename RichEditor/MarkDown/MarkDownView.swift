//
//  MarkDownView.swift
//  RichEditor
//
//  Created by Maple on 2019/8/2.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class MarkDownView: YYTextView {
    // 转为 mark down 格式文本
    var string: String = ""
    // 持有 所有 添加的 控件
    var elements: [MarkDownElement] = [ ]
    /// 文本 风格
    private let style: MarkDownStyle
    /// 文本 编辑时 处理器
    private var processor: AttributesProcessor?
    /// Delegate
    weak var mdDelegate: TextViewDelegate?
    
    required init(frame: CGRect,
                  style: MarkDownStyle) {
        self.style = style
        super.init(frame: frame)
        processor = AttributesProcessor(textView: self, style: self.style)
        delegate = self
        textParser = MarkDownParagraphStyle(style: style)
        isScrollRangeToVisible = false
        isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public
extension MarkDownView {
    /// 富文本编辑
    public func edit(with item: MarkDownItem) {
        let attributedString = attributedText ?? NSAttributedString(string: "")
        let string = NSMutableAttributedString(attributedString: attributedString)
        switch item {
        case .header1, .header2, .header3:
            guard let level = MarkDownHeader.Level(item) else { return }
            let header = MarkDownHeader(level: level, style: style)
            let range = processor?.setElement(header, with: string, at: item, in: currentParagraph())
            attributedText = string
            elements.append(header)
            if let range = range {
                selectedRange = range
            }
        case .done, .undone:
            let todo = MarkDownTodo(style: style, state: .undone)
            todo.tapBlock = { [weak self] button in
                guard let weakSelf = self,
                    let paragraphRange = weakSelf.processor?.findElementRange(at: button) else { return }
                let oldRange = weakSelf.selectedRange
                let item: MarkDownItem = button.isSelected ? .done : .undone
                let attributedString = weakSelf.attributedText ?? NSAttributedString(string: "")
                let string = NSMutableAttributedString(attributedString: attributedString)
                weakSelf.processor?.addAttributed(string, at: item, in: paragraphRange)
                if item == .undone {
                    string.yy_removeAttributes(YYTextStrikethroughAttributeName, range: paragraphRange)
                }
                weakSelf.attributedText = string
                weakSelf.selectedRange = oldRange
            }
            let range = processor?.setElement(todo, with: string, at: item, in: currentParagraph())
            attributedText = string
            elements.append(todo)
            if let range = range {
                selectedRange = range
            }
        case .unordered:
            let unorderd = MarkDownUnordered(style: style)
            let range = processor?.setElement(unorderd, with: string, at: item, in: currentParagraph())
            attributedText = string
            elements.append(unorderd)
            if let range = range {
                selectedRange = range
            }
        case .ordered:
            var range: NSRange?
            var lastElement: MarkDownElement?
            if let range = lastParagraphRange() {
                lastElement = processor?.element(range: range)
            }
            let element = processor?.element(range: selectedRange)
            if element?.item == item {  // 同一标记  移除
                 range = processor?.removeElement(with: string, in: currentParagraph())
            } else {
                var index: Int = 1
                if let originIndex = (lastElement as? MarkDownOrdered)?.index {
                    index = originIndex + 1
                }
                let ordered = MarkDownOrdered(style: style, index: index)
                if element?.item == nil { // 没有标记 添加新的
                    range = processor?.addElement(with: string, element: ordered, in: currentParagraph())
                } else { // 存在标记 替换
                    range = processor?.replaceElement(with: string, element: ordered, in: currentParagraph())
                }
                elements.append(ordered)
            }
            attributedText = string
            if let range = range { selectedRange = range }
        case .separator:
            let separator = MarkDownSeparator(style: style)
            let range = processor?.setElement(separator, with: string, at: item, in: currentParagraph())
            attributedText = string
            elements.append(separator)
            if let range = range {
                selectedRange = range
            }
        }
    }
    
    /// 设置 mark down 文本
    public func parseText(_ text: String, parser: MarkDownParse) {
        let attributedString = parser.parseText(text)
        elements = parser.elements
        attributedText = attributedString
    }
}

// MARK: - Private
extension MarkDownView {
    /// 光标位置 段落 的 范围
    private func currentParagraph() -> NSRange {
        print("Current Paragraph Range: \((text as NSString).paragraphRange(for: selectedRange))")
        return (text as NSString).paragraphRange(for: selectedRange)
    }
    
    /// 上一个段落 range
    private func lastParagraphRange() -> NSRange? {
        let currentParagraphRange = currentParagraph()
        if currentParagraphRange.location > 0 {
            let range = NSRange(location: currentParagraphRange.location - 1, length: 1)
            return (text as NSString).paragraphRange(for: range)
        }
        return nil
    }
}

// MARK: - YYTextViewDelegate
extension MarkDownView: YYTextViewDelegate {
    func textView(_ textView: YYTextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        print("selectedRange: \(selectedRange), text: \(text)")
        textView.typingAttributes = processor?.attributes
        if text == "\n", let element = processor?.element(range: currentParagraph()) {
            let attributedString = attributedText ?? NSAttributedString(string: "")
            let string = NSMutableAttributedString(attributedString: attributedString)
            string.insert(NSAttributedString(string: "\n"), at: selectedRange.location)
            switch element.item {
            case .unordered:
                let unordered = MarkDownUnordered(style: style)
                string.insert(unordered.attributedString!, at: selectedRange.location + 1)
                let range = NSRange(location: selectedRange.location + 2,
                                    length: selectedRange.length)
                attributedText = string
                selectedRange = range
                elements.append(unordered)
                return false
            case .done, .undone:
                let todo = MarkDownTodo(style: style, state: .undone)
                todo.tapBlock = { [weak self] button in
                    guard let weakSelf = self,
                        let paragraphRange = weakSelf.processor?.findElementRange(at: button) else { return }
                    let oldRange = weakSelf.selectedRange
                    let item: MarkDownItem = button.isSelected ? .done : .undone
                    let attributedString = weakSelf.attributedText ?? NSAttributedString(string: "")
                    let string = NSMutableAttributedString(attributedString: attributedString)
                    weakSelf.processor?.addAttributed(string, at: item, in: paragraphRange)
                    if item == .undone {
                        string.yy_removeAttributes(YYTextStrikethroughAttributeName, range: paragraphRange)
                    }
                    weakSelf.attributedText = string
                    weakSelf.selectedRange = oldRange
                }
                string.insert(todo.attributedString!, at: selectedRange.location + 1)
                let range = NSRange(location: selectedRange.location + 2,
                                    length: selectedRange.length)
                attributedText = string
                selectedRange = range
                elements.append(todo)
                return false
            case .ordered:
                let ordered = MarkDownOrdered(style: style, index: (element as! MarkDownOrdered).index + 1)
                string.insert(ordered.attributedString!, at: selectedRange.location + 1)
                let range = NSRange(location: selectedRange.location + 2,
                                    length: selectedRange.length)
                attributedText = string
                selectedRange = range
                elements.append(ordered)
                return false
            default:
                break
            }
        }
        if let mdDelegate = mdDelegate {
            return mdDelegate.textView(self, shouldChangeTextIn: range,
                                       replacementText: text)
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: YYTextView) {
        mdDelegate?.textViewDidBeginEditing(self)
    }
}

// MARK: - TextViewDelegate
protocol TextViewDelegate: NSObjectProtocol {
    func textView(_ textView: MarkDownView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool
    
    func textViewDidBeginEditing(_ textView: MarkDownView)
}

extension TextViewDelegate {
    func textView(_ textView: MarkDownView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool { return true }
    
    func textViewDidBeginEditing(_ textView: MarkDownView) { }
}


class MarkDownParagraphStyle: NSObject, YYTextParser {
    
    let style: MarkDownStyle
    required init(style: MarkDownStyle) {
        self.style = style
        super.init()
    }
    
    func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool {
        text?.yy_lineSpacing = style.paragraphStyle.lineSpacing
        text?.yy_paragraphSpacing = style.paragraphStyle.paragraphSpacing
        return true
    }
}
