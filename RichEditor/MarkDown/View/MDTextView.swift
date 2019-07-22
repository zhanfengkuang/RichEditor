//
//  MDTextView.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/17.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

public class MDTextView: DynamicTextView {
    var imageView: MDImage?
    
    var state: RichEditorElement?
    var isAddMD: Bool = false
    
    var index: Int = 0
    
    var md: String? {
        guard let textLayout = textLayout else { return nil }
        return MDUtil.md(textLayout)
    }
    
    // 光标的位置
    var caretRect: CGRect? {
        guard let position = selectedTextRange?.end else { return nil }
        return caretRect(for: position)
    }
    /// 光标 坐标更新回调
    var caretBlock: ((CGRect) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        isScrollRangeToVisible = false
        placeholderFont = .systemFont(ofSize: 15)
        placeholderText = "请输入详情描述"
        isScrollEnabled = false
        
        maxHeight = 10000
    }
    
    public func editMarkdown(_ element: RichEditorElement, isNewLine: Bool = true) {
        let line = (!text.isEmpty && !text.hasSuffix("\n")) ? "\n" : ""
        switch element {
        case .bold:  // 黑体
            if let textRange = selectedTextRange {
                replace(textRange, withText: element.md)
                let location = selectedRange.location - element.md.count/2
                selectedRange = NSRange(location: location, length: 0)
            }
        case .todo:  // task 任务
            self.state = element
            index = 0
            let location = selectedRange.location + 1 + line.count
            if let textRange = selectedTextRange {
                replace(textRange, withText: line + element.md)
            }
            selectedRange = NSRange(location: location, length: 0)
        case .time:  // 时间
            self.state = nil
            index = 0
            let attachment = MDImage(size: CGSize(width: jr_width, height: 200))
            let text = attributedText.map { NSMutableAttributedString(attributedString: $0) }
            
            print("------- \(selectedRange)")
            
            let currentLocation = selectedRange.location + selectedRange.length
            text?.insert(attachment.attributedString!, at: currentLocation)
//            text?.append(attachment.attributedString!)
            text?.append(NSAttributedString(string: "\r\n"))
            attributedText = text
            imageView = attachment
            
            print("======= \(selectedRange)")
            selectedRange = NSRange(location: currentLocation + 1, length: 0)
            print("+++++++ \(selectedRange)")
            
            print(attributedText)
        case .line:  // 分割线
            index = 0
            let location = selectedRange.location + 1 + line.count + 1
            self.state = nil
            if let textRange = selectedTextRange {
                replace(textRange, withText: line + element.md + "\n")
            }
            selectedRange = NSRange(location: location, length: 0)
        case .unordered:  // 无序
            index = 0
            self.state = element
            if let textRange = selectedTextRange {
                replace(textRange, withText: line + element.md)
            }
        case .header1, .header2, .header3:  // 标题
            index = 0
            self.state = nil
            if let textRange = selectedTextRange {
                replace(textRange, withText: line + element.md)
            }
        case .ordered:  // 有序
            index += 1
            self.state = element
            if let textRange = selectedTextRange {
                replace(textRange, withText: line + index.description + element.md)
            }
        default:
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MDTextView: YYTextViewDelegate {
    public func textView(_ textView: YYTextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        if text == "\n" {
            isAddMD = true
        }
        return true
    }
    
    public func textViewDidChange(_ textView: YYTextView) {
        if isAddMD, let element = state {
            isAddMD = false
            editMarkdown(element, isNewLine: false)
        }
        updateCaret()
        isAddMD = false
    }
    
    public func textViewDidBeginEditing(_ textView: YYTextView) {
        updateCaret()
    }
    
    private func updateCaret() {
        let rect = self.caretRect ?? .zero
        self.caretBlock?(rect)
    }
}

