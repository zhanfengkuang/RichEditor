//
//  MDImage.swift
//  RichEditor
//
//  Created by Maple on 2019/7/10.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

class MDImage: MDControl {
    var attributedString: NSMutableAttributedString?
    
    var type: MDControlType {
        return .image
    }
    
    var md: String {
        return "![image](https://www.baidu.com/123.com)"
    }
    
    required init(size: CGSize = CGSize(width: 100, height: 100)) {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(selectedPicker(_:)), for: .touchUpInside)
        button.frame.size = size
        button.tag = type.rawValue
        button.setImage(UIImage(named: "WechatIMG4306"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: button,
                                                                         contentMode: .left,
                                                                         attachmentSize: size,
                                                                         alignTo: .systemFont(ofSize: 14),
                                                                         alignment: .center)
    }
    
    @objc func selectedPicker(_ sender: UIButton) {
        sender.setImage(UIImage(named: "屏幕快照 2019-07-22 16.18.15"), for: .normal)
    }
}
