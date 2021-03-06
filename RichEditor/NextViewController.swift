//
//  NextViewController.swift
//  RichEditor
//
//  Created by Maple on 2019/7/11.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
    
    required init(attributedString: NSAttributedString) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let btn = UIButton(type: .custom)
        btn.setTitle("back", for: .normal)
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
