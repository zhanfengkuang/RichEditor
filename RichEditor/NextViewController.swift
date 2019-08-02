//
//  NextViewController.swift
//  RichEditor
//
//  Created by Maple on 2019/7/11.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
    
    var textView: MDTextView!
    
    required init(attributedString: NSAttributedString) {
        super.init(nibName: nil, bundle: nil)
        let style = MarkDownStyle()
        
        textView = MDTextView(frame: CGRect(x: 20, y: 100, width: screenWidth - 40, height: 300))
        textView.style = style
        textView.isEditable = false
        textView.attributedText = attributedString
        textView.textParser = MarkDownParse(style: style, textView: textView)
        view.addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
//        let textView = UITextView()
//        textView.frame = CGRect(x: 0, y: 100, width: 375, height: 200)
//        view.addSubview(textView)
        
        
        let btn = UIButton(type: .custom)
        btn.setTitle("next", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        view.addSubview(btn)
        btn.frame = CGRect(x: 100, y: 400, width: 200, height: 30)
    }
    
    @objc func nextAction() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("next view controller")
    }
}
