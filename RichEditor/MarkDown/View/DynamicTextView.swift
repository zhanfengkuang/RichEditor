//
//  DynamicTextView.swift
//  Record
//
//  Created by Maple on 2018/12/6.
//  Copyright © 2018 TanKe. All rights reserved.
//

import UIKit

// text view 会根据文本内容的高度而改变
public class DynamicTextView: TextView {
    /// 默认高度
    var defaultHeight: CGFloat = 60,
    /// textView 的最大高度
    maxHeight: CGFloat = screenHeight
    
    /// 当期的高度
    private(set) var currentHeight: CGFloat = 60
    /// text view 高度改变后回调
    var observeHeight: ((CGFloat) -> Void)?
    /// 偏移量 更新 回调
    var contentOffsetBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        KeyboardManager.shared.keyboardDidShow = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.sizeThatFits(weakSelf.bounds.size)
        }
    }
    
    override public func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == "contentSize",
            currentHeight != contentSize.height { // 文本高度为改变不处理
            currentHeight = contentSize.height
            if (defaultHeight...maxHeight).contains(currentHeight) { // 将文本的高度控制在该范围内
                // jarmon_tip: 不设置动画 会出现 textview 跳动问题
                UIView.defaultAnimate(animations: {
                    self.frame = CGRect(origin: self.frame.origin,
                                        size: CGSize(width: self.bounds.size.width,
                                                     height: self.currentHeight))
                })
//                extraContainerView.frame = bounds
                printLog(currentHeight)
                observeHeight?(currentHeight)
            }
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "contentSize")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
