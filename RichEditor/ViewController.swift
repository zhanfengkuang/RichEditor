//
//  ViewController.swift
//  RichEditor
//
//  Created by Maple on 2019/7/7.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /// rich editor toolbar
    var richEditorToolbar: RichEditorToobar!
    /// rich editor
    var richEditor: MDTextView!
    /// rich text parser
    var parser: MDParser = MDParser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        richEditorToolbar = RichEditorToobar(frame: CGRect(x: 0, y: screenHeight - 80, width: screenWidth, height: 40), module: .todo)
        view.addSubview(richEditorToolbar)
        richEditorToolbar.show()
        KeyboardManager.shared.heightChange = { [weak self] height in
            self?.richEditorToolbar.jr_y = screenHeight - 60 - height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.richEditor = MDTextView(frame: CGRect(x: 50, y: 54, width: screenWidth - 70, height: 300))
            self.richEditor.textParser = self.parser
            self.view.addSubview(self.richEditor)
            
            self.richEditorToolbar.textView = self.richEditor
        }
    }
    
    deinit {
        MDUtil.controls = [ ]
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
