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
    
    required init(frame: CGRect,
                  style: MarkDownStyle) {
        self.style = style
        super.init(frame: frame)
        processor = MarkDownProcessor(textView: self, style: self.style)
        showsVerticalScrollIndicator = false
//        delegate = self
        textParser = MarkDownParagraphStyle(style: style)
//        isScrollRangeToVisible = false
//        isScrollEnabled = false
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
        case .quote:
            let quote = MarkDownQuote(style: style)
            let range = processor?.setElement(quote, with: string, at: item, in: currentParagraph())
            attributedText = string
            elements.append(quote)
            if let range = range {
                selectedRange = range
            }
        case .separator:
            let separator = MarkDownSeparator(style: style)
            let range = processor?.setElement(separator, with: string, at: item, in: currentParagraph())
            attributedText = string
            elements.append(separator)
            if let range = range {
                selectedRange = range
            }
        case .image:
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
                                    length: weakSelf.selectedRange.length)
                string.insert(image.attributedString!, at: weakSelf.selectedRange.location)
                weakSelf.attributedText = string
                weakSelf.elements.append(image)
                weakSelf.selectedRange = range
                weakSelf.becomeFirstResponder()
            }
            AppUtil.fetchCurrentVC()?.present(vc, animated: true, completion: nil)
            break
        case .bold, .highlighter, .italic, .underline, .strikethrough:
            guard let elementStyle = style.attributes(with: item) else { return }
            if isSelected {
                processor?.markAttributes.merge(elementStyle) { return $1 }
            } else {
                elementStyle.forEach { (key, _) in
                    processor?.markAttributes.removeValue(forKey: key)
                }
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
extension MarkDownTextView {
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
            print("update selected range: \(range)")
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
//extension MarkDownTextView: YYTextViewDelegate {
extension MarkDownTextView {
    override func textView(_ textView: YYTextView,
                           shouldChangeTextIn range: NSRange,
                           replacementText text: String) -> Bool {
        textView.typingAttributes = processor?.attributes
        print("typing attributes: \(typingAttributes)")
        if text == "\n", let element = processor?.element(range: currentParagraph()) {
            processor?.markAttributes.removeAll()
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