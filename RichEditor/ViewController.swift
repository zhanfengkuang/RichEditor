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
    /// text view
    var editor: MarkDownTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        richEditorToolbar = RichEditorToobar(frame: CGRect(x: 0, y: screenHeight - 80, width: screenWidth, height: 40), module: .todo)
        view.addSubview(richEditorToolbar)
        richEditorToolbar.show()
        KeyboardManager.shared.heightChange = { [weak self] height in
            self?.richEditorToolbar.jr_y = screenHeight - 60 - height
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.editor = MarkDownTextView(frame: CGRect(x: 50, y: 54, width: screenWidth - 70, height: screenHeight - 120), style: .init())
            self.editor.toolBar = self.richEditorToolbar
            self.view.insertSubview(self.editor, belowSubview: self.richEditorToolbar)
            self.richEditorToolbar.textView = self.editor
        }
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
