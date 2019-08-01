//
//  TextProcessor.swift
//  RichEditor
//
//  Created by Maple on 2019/7/30.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

struct TextProcessor {
    weak var textView: YYTextView?
    
    init(textView: YYTextView?) {
        self.textView = textView
    }
    
    func addAttributes(_ text: String) -> [String: Any?] {
        if text.count > 1 {
            return [NSAttributedString.Key.foregroundColor.rawValue: UIColor.orange,
                    NSAttributedString.Key.font.rawValue: UIFont.boldSystemFont(ofSize: 20),
                    NSAttributedString.Key.strikethroughStyle.rawValue: nil]
        }
        return [NSAttributedString.Key.foregroundColor.rawValue: UIColor.lightGray,
                NSAttributedString.Key.font.rawValue: UIFont.systemFont(ofSize: 15),
                NSAttributedString.Key.strikethroughStyle.rawValue: NSUnderlineStyle.single.rawValue]
    }
}
