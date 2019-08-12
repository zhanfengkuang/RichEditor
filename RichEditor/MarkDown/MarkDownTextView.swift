//
//  MarkDownTextView.swift
//  RichEditor
//
//  Created by Maple on 2019/8/2.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class MarkDownTextView: YYTextView {
    // 转为 mark down 格式文本
    var string: String = ""
    // 持有 所有 添加的 控件
    var elements: [MarkDownElement] = [ ]
    /// 文本 风格
    private let style: MarkDownStyle
    /// 文本 编辑时 处理器
    private var processor: MarkDownProcessor?
    /// Delegate
    weak var mdDelegate: TextViewDelegate?
    weak var toolBar: RichEditorToobar?
    
    required init(frame: CGRect,
                  style: MarkDownStyle) {
        self.style = style
        super.init(frame: frame)
        bottomOffset = 100
        processor = MarkDownProcessor(textView: self, style: self.style)
        showsVerticalScrollIndicator = false
        textParser = MarkDownParagraphStyle(style: style)
        // 处理 图片无法滑动
        delaysContentTouches = true
        canCancelContentTouches = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public
extension MarkDownTextView {
    /// 富文本编辑
    public func edit(with item: MarkDownItem, isSelected: Bool) {
        let attributedString = attributedText ?? NSAttributedString(string: "")
        let string = NSMutableAttributedString(attributedString: attributedString)
        switch item {
        case .header1, .header2, .header3:
            guard let level = MarkDownHeader.Level(item) else { return }
            unmarkText()
            let header = MarkDownHeader(level: level, style: style)
            let range = processor?.setElement(header, with: string, at: item, in: currentParagraph())
            setAttributedText(string, range)
            elements.append(header)
        case .done, .undone:
            unmarkText()
            let todo = MarkDownTodo(style: style, state: .undone)
            todo.tapBlock = { [weak self] button in
                guard let weakSelf = self,
                    let paragraphRange = weakSelf.processor?.findElementRange(at: button) else { return }
                weakSelf.unmarkText()
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
            setAttributedText(string, range)
            elements.append(todo)
        case .unordered:
            unmarkText()
            let unorderd = MarkDownUnordered(style: style)
            let range = processor?.setElement(unorderd, with: string, at: item, in: currentParagraph())
            setAttributedText(string, range)
            elements.append(unorderd)
        case .ordered:
            unmarkText()
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
            setAttributedText(string, range)
        case .quote:
            unmarkText()
            let quote = MarkDownQuote(style: style)
            let range = processor?.setElement(quote, with: string, at: item, in: currentParagraph())
            setAttributedText(string, range)
            elements.append(quote)
        case .separator:
            unmarkText()
            let separator = MarkDownSeparator(style: style)
            let range = processor?.setElement(separator, with: string, at: item, in: currentParagraph())
            setAttributedText(string, range)
            elements.append(separator)
        case .image:
            unmarkText()
            guard let vc = TZImagePickerController(maxImagesCount: 1, delegate: self) else { return }
            vc.didFinishPickingPhotosHandle = { [weak self] (photos, assets, isOriginal) in
                guard let weakSelf = self else { return }
                guard let photo = photos?.first else { return }
                let image = MarkDownImage(style: weakSelf.style,
                                          size: CGSize(width: weakSelf.jr_width - 10, height: 200),
                                          image: photo)
                image.tapBlock = { button in
                    guard let vc = TZImagePickerController(maxImagesCount: 1, delegate: self) else { return }
                    vc.didFinishPickingPhotosHandle = { (photos, _, _) in
                        guard let photo = photos?.first else { return }
                        button.setImage(photo, for: .normal)
                    }
                    AppUtil.fetchCurrentVC()?.present(vc, animated: true, completion: nil)
                }
                let range = NSRange(location: weakSelf.selectedRange.location + 3,
                                    length: 0)
                string.insert(image.attributedString!, at: weakSelf.selectedRange.location)
                weakSelf.attributedText = string
                weakSelf.elements.append(image)
                weakSelf.selectedRange = range
                weakSelf.becomeFirstResponder()
            }
            AppUtil.fetchCurrentVC()?.present(vc, animated: true, completion: nil)
            break
        case .bold, .highlighter, .italic:
            guard let elementStyle = style.attributes(with: item) else { return }
            if isSelected {
                processor?.markAttributes.merge(elementStyle) { return $1 }
                addSelectedAttributes(at: item)
            } else {
                elementStyle.forEach { (key, _) in
                    processor?.markAttributes.removeValue(forKey: key)
                }
                removeSelectedAttributes(at: item)
            }
        case .strikethrough:
            let strikethrounghStyle = style.attributes[.strikethrough] as? MarkDownStrikethroughStyle ?? MarkDownStrikethroughStyle()
            let decoration = YYTextDecoration(style: .single, width: 1, color: isSelected ? strikethrounghStyle.color : .clear )
            processor?.markAttributes.updateValue(decoration, forKey: YYTextStrikethroughAttributeName)
            isSelected ? addSelectedAttributes(at: item) : removeSelectedAttributes(at: item)
        case .underline:
            let underlineStyle = style.attributes[.strikethrough] as? MarkDownUnderlineStyle ?? MarkDownUnderlineStyle()
            let color: UIColor = isSelected ? underlineStyle.color : .clear
            let decoration = YYTextDecoration(style: .single, width: 1, color:  color)
            processor?.markAttributes.updateValue(decoration, forKey: YYTextUnderlineAttributeName)
            isSelected ? addSelectedAttributes(at: item) : removeSelectedAttributes(at: item)
        }
    }
    
    /// 设置 mark down 文本
    public func parseText(_ text: String, parser: MarkDownParser) {
        let attributedString = parser.parseText(text)
        elements = parser.elements
        attributedText = attributedString
    }
}

// MARK: - Private
extension MarkDownTextView {
    /// 给选中的 文本添加属性
    private func addSelectedAttributes(at item: MarkDownItem) {
        guard selectedRange.length > 0,
            let string = attributedText,
            var attributes = style.attributes(with: item) else { return }
        let range = selectedRange
        let selectedString = string.attributedSubstring(from: selectedRange)
        if let originalAttributes = selectedString.yy_attributes {
            attributes.merge(originalAttributes) { (current, _) in current }
        }
        let mutableSelectedString = NSMutableAttributedString(attributedString: selectedString)
        for attribute in attributes.enumerated() {
            if mutableSelectedString.length <= range.length {
                mutableSelectedString.yy_setAttribute(attribute.element.key,
                                                      value: attribute.element.value,
                                                      range: NSRange(location: 0, length: range.length))
            }
        }
        let originalString = NSMutableAttributedString(attributedString: string)
        originalString.replaceCharacters(in: range, with: mutableSelectedString)
        attributedText = originalString
        selectedRange = range
    }
    
    /// 移除 选中 文本的属性
    private func removeSelectedAttributes(at item: MarkDownItem) {
        guard selectedRange.length > 0,
            let string = attributedText else { return }
        let range = selectedRange
        let selectedString = string.attributedSubstring(from: selectedRange)
        var attributes: [String: Any] = [ : ]
        let mutableSelectedString = NSMutableAttributedString(attributedString: selectedString)
        switch item {
        case .bold:
            if let value = processor?.attributes?[.font] {
                attributes[.font] = value
            } else {
                attributes[.font] = style.font
            }
        case .italic:
            attributes[.font] = style.font
        case .highlighter:
            attributes[.backgroundColor] = UIColor.clear
        case .strikethrough:
            if let value = processor?.attributes?[YYTextStrikethroughAttributeName] {
                attributes[YYTextStrikethroughAttributeName] = value
            } else {
                let decoration = YYTextDecoration(style: .single, width: 0, color:  .clear)
                attributes[YYTextStrikethroughAttributeName] = decoration
            }
            mutableSelectedString.yy_removeAttributes(YYTextStrikethroughAttributeName,
                                                      range: NSRange(location: 0, length: mutableSelectedString.length))
        case .underline:
            if let value = processor?.attributes?[YYTextUnderlineAttributeName] {
                attributes[YYTextUnderlineAttributeName] = value
            } else {
                let decoration = YYTextDecoration(style: .single, width: 0, color:  .clear)
                attributes[YYTextUnderlineAttributeName] = decoration
            }
            mutableSelectedString.yy_removeAttributes(YYTextUnderlineAttributeName,
                                                      range: NSRange(location: 0, length: mutableSelectedString.length))
        default:
            return
        }
        if let originalAttributes = selectedString.yy_attributes {
            attributes.merge(originalAttributes) { (current, _) in current }
        }
        for attribute in attributes.enumerated() {
            if mutableSelectedString.length <= range.length {
                mutableSelectedString.yy_setAttribute(attribute.element.key,
                                                      value: attribute.element.value,
                                                      range: NSRange(location: 0, length: range.length))
            }
        }
        let originalString = NSMutableAttributedString(attributedString: string)
        originalString.replaceCharacters(in: range, with: mutableSelectedString)
        attributedText = originalString
        selectedRange = range
    }
    
    private func setAttributedText(_ text: NSAttributedString, _ selectedRange: NSRange?) {
        // 处理 设置 标记点 时 屏幕会上下滚动
        isScrollRangeToVisible = false
        attributedText = text
        if let range = selectedRange {
            self.selectedRange = range
            isScrollRangeToVisible = true
        }
    }
    
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
    
    // 监听 光标 移动
    private func addListen() {
        addObserver(self, forKeyPath: "selectedRange", options: .new, context: nil)
    }
    
    // 移除监听
    private func removeListen() {
        removeObserver(self, forKeyPath: "selectedRange")
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedRange",
            let range = change?[.newKey] as? NSRange {
//            print("update selected range: \(range)")
            if let string = attributedText, string.length > 0 {
                let location = max(0, range.location)
                let length = 1
                if location + length <= string.length {
                    let last = string.attributedSubstring(from: NSRange(location: max(0, range.location), length: 1))
                    if let style = last.yy_attributes {
                        processor?.markAttributes.merge(style) { (_, new) in new }
                    }
                }
            }
        }
    }
}

// MARK: - YYTextViewDelegate
extension MarkDownTextView {
    override func textView(_ textView: YYTextView,
                           shouldChangeTextIn range: NSRange,
                           replacementText text: String) -> Bool {
        textView.typingAttributes = processor?.attributes
//        print("typing attributes: \(typingAttributes)")
        if text == "\n" {
            processor?.markAttributes.removeAll()
            textView.typingAttributes = processor?.attributes
            // 换行清掉原有的 属性
            toolBar?.resetMark()
            if let element = processor?.element(range: currentParagraph()) {
                let attributedString = attributedText ?? NSAttributedString(string: "")
                let string = NSMutableAttributedString(attributedString: attributedString)
                string.insert(NSAttributedString(string: "\n"), at: selectedRange.location)
                switch element.item {
                case .unordered:
                    unmarkText()
                    let unordered = MarkDownUnordered(style: style)
                    string.insert(unordered.attributedString!, at: selectedRange.location + 1)
                    let range = NSRange(location: selectedRange.location + 2,
                                        length: 0)
                    setAttributedText(string, range)
                    elements.append(unordered)
                    return false
                case .done, .undone:
                    unmarkText()
                    let todo = MarkDownTodo(style: style, state: .undone)
                    todo.tapBlock = { [weak self] button in
                        guard let weakSelf = self,
                            let paragraphRange = weakSelf.processor?.findElementRange(at: button) else { return }
                        weakSelf.unmarkText()
                        let oldRange = weakSelf.selectedRange
                        let item: MarkDownItem = button.isSelected ? .done : .undone
                        let attributedString = weakSelf.attributedText ?? NSAttributedString(string: "")
                        let string = NSMutableAttributedString(attributedString: attributedString)
                        weakSelf.processor?.addAttributed(string, at: item, in: paragraphRange)
                        if item == .undone {
                            string.yy_removeAttributes(YYTextStrikethroughAttributeName, range: paragraphRange)
                        }
                        weakSelf.setAttributedText(string, oldRange)
//                        weakSelf.attributedText = string
//                        weakSelf.selectedRange = oldRange
                    }
                    string.insert(todo.attributedString!, at: selectedRange.location + 1)
                    let range = NSRange(location: selectedRange.location + 2,
                                        length: 0)
                    setAttributedText(string, range)
                    elements.append(todo)
                    return false
                case .ordered:
                    unmarkText()
                    let ordered = MarkDownOrdered(style: style, index: (element as! MarkDownOrdered).index + 1)
                    string.insert(ordered.attributedString!, at: selectedRange.location + 1)
                    let range = NSRange(location: selectedRange.location + 2,
                                        length: 0)
                    setAttributedText(string, range)
                    elements.append(ordered)
                    return false
                default:
                    break
                }
            }
        }
        if let mdDelegate = mdDelegate {
            return mdDelegate.textView(self, shouldChangeTextIn: range,
                                       replacementText: text)
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: YYTextView) {
//        mdDelegate?.textViewDidBeginEditing(self)
    }
}

// MARK: - Touch
extension MarkDownTextView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        if let string = attributedText, string.length > 0 {
//            let location = max(0, selectedRange.location - 1)
//            let length = 1
//            if location + length <= string.length {
//                let last = string.attributedSubstring(from: NSRange(location: location, length: length))
//                if let attributes = last.yy_attributes {
//                    var newAttributes: [String: Any] = [ : ]
//                    processor?.markAttributes.merge(attributes) { (_, new) in new }
//                }
//            }
//        }
    }
}

// MARK: - 照片 选择器
extension MarkDownTextView: TZImagePickerControllerDelegate {
    
}

// MARK: - TextViewDelegate
protocol TextViewDelegate: NSObjectProtocol {
    func textView(_ textView: MarkDownTextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool
    
    func textViewDidBeginEditing(_ textView: MarkDownTextView)
}

extension TextViewDelegate {
    func textView(_ textView: MarkDownTextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool { return true }
    
    func textViewDidBeginEditing(_ textView: MarkDownTextView) { }
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
