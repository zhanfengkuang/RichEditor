//
//  MDLine.swift
//  Record
//
//  Created by Maple on 2019/5/24.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

class MDLine: MDControl {
    var type: MDControlType = .line
    var md: String { return "----" }
    var attributedString: NSMutableAttributedString?
    
    required init(size: CGSize = CGSize(width: screenWidth - 70, height: 1)) {
        let line = UIView()
        line.size = size
        line.backgroundColor = UIColor(hex: 0xEEEEEE)
        line.tag = type.rawValue
        

        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: line,
                                                                         contentMode: .center,
                                                                         attachmentSize: size,
                                                                         alignTo: .systemFont(ofSize: 15),
                                                                         alignment: .top)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
