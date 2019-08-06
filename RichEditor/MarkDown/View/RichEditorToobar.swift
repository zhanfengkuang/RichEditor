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
            return [.header1, .header2, .header3, .undone, .separator, .ordered, .unordered]
        }
    }
    
    // 关闭按钮
    private var closeBtn: UIButton!
    private var scrollView: UIScrollView!
    private(set) var module: Module
    weak var textView: MarkDownView?
    
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
        richEditor.edit(with: element)
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
        }
    }
    
    var image: UIImage? {
        return UIImage(named: "editor_toolbar_" + name + "_normal")
    }
}

public enum RichEditorElement: Int, CaseIterable {
    /// 黑体
    case bold = 10
    /// 斜体
    case italic
    /// 下划线
    case underline
    /// 中划线
    case strikeThrough
    /// 标题1
    case header1
    /// 标题2
    case header2
    /// 标题3
    case header3
    /// 无序
    case unordered
    /// 有序
    case ordered
    /// 时间
    case time
    /// 分割线
    case line
    /// task list
    case todo
    /// 无序
    
    /// 图片
    case image
    
    var name: String {
        switch self {
        case .bold:
            return "bold"
        case .italic:
            return "italic"
        case .underline:
            return "underline"
        case .strikeThrough:
            return "strikeThrough"
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
        case .time:
            return "time"
        case .line:
            return "line"
        case .todo:
            return "todo"
        case .image:
            return "image"
        }
        
    }
    var md: String {
        switch self {
        case .bold:
            return "****"
        case .todo:
            return "- [ ] "
        case .line:
            return "----"
        case .unordered:
            return "• "
        case .header1:
            return "# "
        case .header2:
            return "## "
        case .header3:
            return "### "
        case .ordered:
            return ". "
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        return UIImage(named: "editor_toolbar_" + name + "_normal")
    }
}
