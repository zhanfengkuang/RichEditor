//
//  MDTaskList.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/18.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

class MDTaskList: MDControl {
    var type: MDControlType = .task
    var md: String { return state.rawValue }
    
    var attributedString: NSMutableAttributedString?
    
    enum State: String, CaseIterable {
        /// 已完成
        case done = "- [x] "
        /// 未完成
        case undone = "- [ ] "
        
        var count: Int { return self.rawValue.count }
    }
    
    var state: State
    
    required init(state: State, size: CGSize = CGSize(width: 25, height: 15)) {
        self.state = state
        let button = UIButton(type: .custom)
        button.isSelected = state == .done
        button.setImage(UIImage(named: "rich_text_todo_done"), for: .selected)
        button.setImage(UIImage(named: "rich_text_todo_undone"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.frame.size = size
        button.addTarget(self, action: #selector(changeState), for: .touchUpInside)
        button.tag = type.rawValue
        
        attributedString = NSMutableAttributedString.yy_attachmentString(withContent: button,
                                                                         contentMode: .left,
                                                                         attachmentSize: size,
                                                                         alignTo: .systemFont(ofSize: 14),
                                                                         alignment: .center)
    }
    
    @objc func changeState(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        state = sender.isSelected ? .done : .undone
        
//        VibrationUril.vibrationUril(type: .light)
    }
    
    deinit { print("被释放了😔") }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
