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
    
    var button: UIButton!
    
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
            
//            self.richEditor.attributedText = NSAttributedString(string: "- [x] halzi\n![image](https://www.baidu.com/123.com)\n- [x] halzi\n![image](https://www.baidu.com/123.com)\n- [x] halzi\n![image](https://www.baidu.com/123.com)")
            
             self.richEditor.attributedText = NSAttributedString(string: "")
            self.richEditorToolbar.textView = self.richEditor
            self.richEditor.delegate = self
        }
        
//        let btn = UIButton(type: .custom)
//        btn.setTitle("next", for: .normal)
//        btn.setTitleColor(.red, for: .normal)
//        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
//        view.addSubview(btn)
//        btn.frame = CGRect(x: 100, y: 400, width: 200, height: 30)
        
        
    }
    
    @objc func nextAction() {
        let vc = NextViewController()
//        richEditor.isEditable = false
        present(vc, animated: true, completion: nil)
    }
    
    deinit {
        NSAttributedString.Key.font
        MDUtil.controls = [ ]
    }
}

extension ViewController: YYTextViewDelegate {
    
    func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        print(textView.attributedText, range)
        
        if let att = textView.attributedText {
            
            
            att.enumerateAttribute(.font, in: att.yy_rangeOfAll(), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
                print("===============  value: \(value), range: \(range)")
            }
        }
        
        
        
        return true
    }
    
    func textViewDidChange(_ textView: YYTextView) {
        guard let text = textView.attributedText,
            var style = text.yy_paragraphStyle else { return }
        
//        var tab = NSTextTab(textAlignment: .natural, location: 15 * 6, options: [:])
//        style.tabStops = [tab]
//
//
//        [ addAttribute:NSParagraphStyleAttributeName value:style range: NSRange];
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
