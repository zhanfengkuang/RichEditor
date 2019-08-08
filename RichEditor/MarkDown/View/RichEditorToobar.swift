//
//  RichEditorToobar.swift
//  SwiftMarkDown
//
//  Created by Maple on 2019/5/21.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit

public class RichEditorToobar: UIView {
    
    public enum Module: String {
        // 长短文
        case note
        // 待办
        case todo
        
        var elements: [MarkDownItem] {
            return [.image, .header1, .header2, .header3, .undone,
                    .separator, .ordered, .unordered, .bold, .highlighter,
                    .italic, .underline, .strikethrough, .quote]
        }
    }
    
    // 关闭按钮
    private var closeBtn: UIButton!
    private var scrollView: UIScrollView!
    private(set) var module: Module
    weak var textView: MarkDownTextView?
    
    required init(frame: CGRect, module: Module) {
        self.module = module
        super.init(frame: frame)
        setupUI()
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - public
extension RichEditorToobar {
    // 显示视图
    public func show() {
        let originWidth = jr_width
        jr_width = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.jr_width = originWidth
            self.closeBtn.jr_x = originWidth - self.closeBtn.jr_width
        })
    }
}

// MARK: - action
extension RichEditorToobar {
    @objc func closeAction() {
        UIView.animate(withDuration: 0.4, animations: {
            self.jr_width = 0
            self.closeBtn.jr_x = -self.closeBtn.jr_width
        }) { (result) in
            self.removeFromSuperview()
        }
    }
    
    // 按钮 编辑 富文本
    @objc func editAction(_ sender: UIButton) {
        // 不是处于编辑状态 禁止编辑
        guard let richEditor = textView, richEditor.isFirstResponder,
            let element = MarkDownItem(rawValue: sender.tag) else { return }
        sender.isSelected.toggle()
        richEditor.edit(with: element, isSelected: sender.isSelected)
    }
}

extension RichEditorToobar {
    private func setupUI() {
        layer.masksToBounds = true
        let closeBtnWidth: CGFloat = 40
        
        // 滚动图
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = bounds.addW(-closeBtnWidth)
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(scrollView)
        
        let separateLine = UIView(frame: CGRect(x: 0, y: 0, width: jr_width, height: 1))
        separateLine.backgroundColor = UIColor(hex: 0xEEEEEE)
        addSubview(separateLine)
        
        for (index, element) in module.elements.enumerated() {
            let btn = UIButton(type: .custom)
            btn.addTarget(self, action: #selector(editAction(_:)), for: .touchUpInside)
            btn.setImage(element.image, for: .normal)
            btn.setImage(element.selectedImage, for: .selected)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.tag = element.rawValue
            btn.frame = CGRect(x: jr_height*index.cgFloat, y: 0,
                               width: jr_height, height: jr_height)
            scrollView.addSubview(btn)
        }
        scrollView.contentSize = CGSize(width: (module.elements.count + 1).cgFloat*jr_height, height: jr_height)
        
        closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage(named: "editor_toolbar_close"), for: .normal)
        closeBtn.frame = CGRect(x: -closeBtnWidth, y: 0,
                                width: closeBtnWidth, height: jr_height)
        closeBtn.backgroundColor = .white
        closeBtn.imageView?.contentMode = .scaleAspectFit
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        addSubview(closeBtn)
        
        let line = UIView(frame: CGRect(x: jr_width - closeBtnWidth - 1, y: 0, width: 1, height: jr_height))
        line.backgroundColor = UIColor(hex: 0xEEEEEE)
        addSubview(separateLine)
    }
}

// MARK: - Public
extension RichEditorToobar {
    /// 重置 所有标记 属性
    public func resetMark() {
        scrollView.subviews.forEach {
            ($0 as? UIButton)?.isSelected = false
        }
    }
}

extension MarkDownItem {
    var name: String {
        switch self {
        case .header1:
            return "header1"
        case .header2:
            return "header2"
        case .header3:
            return "header3"
        case .unordered:
            return "unordered"
        case .ordered:
            return "ordered"
        case .separator:
            return "line"
        case .done, .undone:
            return "todo"
        case .image:
            return "image"
        case .bold:
            return "bold"
        case .highlighter:
            return "highlighter"
        case .strikethrough:
            return "strikethrough"
        case .italic:
            return "italic"
        case .underline:
            return "underline"
        case .quote:
            return "quote"
        }
    }
    
    var image: UIImage? {
        return UIImage(named: "editor_toolbar_" + name + "_normal")
    }
    
    var selectedImage: UIImage? {
        return UIImage(named: "editor_toolbar_" + name + "_selected")
    }
}
