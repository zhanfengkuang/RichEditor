//
//  MDParser.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/18.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

class MDParser: YYTextSimpleMarkdownParser {
    override init() {
        super.init()
        fontSize = 15
        textColor = UIColor(hex: 0x6D7278)
        headerTextColor = textColor
    }
    
    override func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool {
        text?.yy_lineSpacing = 8
        let result = super.parseText(text, selectedRange: selectedRange)
        print(text?.string ?? "")
        
        if let att = text {
            MDUtil.parserToControl(text: att, range: selectedRange)
        }
        
        return result
    }
    
    @objc func change(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}
