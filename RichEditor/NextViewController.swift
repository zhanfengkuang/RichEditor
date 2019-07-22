//
//  NextViewController.swift
//  RichEditor
//
//  Created by Maple on 2019/7/11.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 100, width: 375, height: 200)
        view.addSubview(textView)
        
        
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
}
