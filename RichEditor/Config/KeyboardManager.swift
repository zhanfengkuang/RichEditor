//
//  KeyboardManager.swift
//  Record
//
//  Created by Maple on 2018/9/12.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import Foundation

/*
 
                !!!  使用前注意  !!!
    要在使用类中 deinit方法中将 heightChange 置为 nil
    当heightChange 持有被释放的对象会出现崩溃
 */

// 键盘管理
class KeyboardManager {
    static let shared = KeyboardManager()
    
    /// 获取键盘高度回调
    var heightChange: ((CGFloat) -> Void)?
    
    var keyboardDidShow: (() -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        heightChange?(0)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let bounds = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        heightChange?(bounds.size.height)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
