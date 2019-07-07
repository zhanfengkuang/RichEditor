
//
//  MDUtil.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/20.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

struct MDUtil {
    static var controls: [MDControl] = [ ]
    
    /// 将富文本转为 md 标记
    ///
    /// - Parameter textLayout: 富文本信息
    /// - Returns: md
    static func md(_ textLayout: YYTextLayout) -> String {
        guard let attachments = textLayout.attachments,
            let textRange = textLayout.attachmentRanges else {
            return textLayout.text.string
        }
        /// 不包含控件文本
        var md = textLayout.text.string
        var offset: Int = 0
        for (index, att) in attachments.enumerated() {
            if let view = att.content as? UIView,
                var location = (textRange.element(at: index) as? NSRange)?.location,
                let type = MDControlType(rawValue: view.tag) {
                let control: MDControl
                switch type {
                case .task:
                    let btn = view as! UIButton
                    control = MDTaskList(state: btn.isSelected ? .done : .undone)
                case .line:
                    control = MDLine()
                }
                location += offset
                md.insert(contentsOf: control.md, at: md.index(md.startIndex, offsetBy: location))
                offset += control.md.count
            }
        }
        return md
    }
    
    static func md(text: NSMutableAttributedString) {
        
    }
    
    static func parserToText(_ text: NSMutableAttributedString, range: NSRangePointer?) {
        var offset: Int = 0
        var selectedRange: NSRange = range == nil ? NSRange(location: 0, length: 0) : range!.pointee
        if let textLayout = YYTextLayout(containerSize: CGSize(width: 375, height: 300), text: text),
            let attachments = textLayout.attachments,
            let textRange = textLayout.attachmentRanges {
            for (index, attachment) in attachments.enumerated() {
                if let btn = attachment.content as? UIButton {
                    let control = MDTaskList(state: btn.isSelected ? .done : .undone)
                    if let matchRange = (textRange.element(at: index) as? NSRange) {
                        let location = matchRange.location
                        let att = NSMutableAttributedString(string: control.md)
//                        att.yy_setTextBackedString(YYTextBackedString(string: att.), range: <#T##NSRange#>)
                        // 代替富文本的位置
                        let replaceRange = NSRange(location: location + offset, length: 1)
                        text.yy_setAttachment(nil, range: replaceRange)
                        offset += control.md.count
                        
                        selectedRange = YYTextSimpleMarkdownParser()._replaceText(in: replaceRange,
                                                                                  withLength: UInt(att.length),
                                                                                  selectedRange: selectedRange)
                    }
                }
            }
            range?.pointee = selectedRange
            print( "============= \(textLayout.text)" )
        }
    }
    
    static func parserToControl(text: NSMutableAttributedString, range: NSRangePointer?) {
        MDControlType.allCases.forEach {
            switch $0 {
            case .task:
                for state in MDTaskList.State.allCases {
                    var offset: Int = 0
                    let ranges = text.string.nsranges(of: state.rawValue)
                    for range in ranges {
                        let location = range.location - offset
                        if location < 0 { continue }
                        let replaceRange = NSRange(location: location , length: state.count)
                        let control = MDTaskList(state: state)
                        MDUtil.controls.append(control)
                        if let attributedString = control.attributedString {
                            text.replaceCharacters(in: replaceRange, with: attributedString)
                        }
                        offset += state.count - $0.count
                    }
                }
            case .line:
                var offset: Int = 0
                let ranges = text.string.nsranges(of: MDLine().md)
                for range in ranges {
                    let line = MDLine()
                    let location = range.location - offset
                    if location < 0 { continue }
                    let replaceRange = NSRange(location: location , length: line.md.count)
                    MDUtil.controls.append(line)
                    if let attributedString = line.attributedString {
                        text.replaceCharacters(in: replaceRange, with: attributedString)
                    }
                    offset += line.md.count - $0.count
                }
            }
        }
    }
}
