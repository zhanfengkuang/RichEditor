//
//  UIViewExt.swift
//  Record
//
//  Created by Maple on 2018/9/11.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import UIKit

extension UIView {
    // 圆角的风格
    enum CornerStyle {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
        case all
        case none
    }
}

// MARK: - shadow
extension UIView {
    /// 阴影
    ///
    /// - Parameters:
    ///   - color: 阴影颜色
    ///   - offset: 偏移量
    ///   - radius: 阴影圆角半径
    func setShadow(_ color: UIColor, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - layer
extension UIView {
    
    /// 设置圆角
    ///
    /// - Parameters:
    ///   - rect: 圆角frame
    ///   - corners: 圆角位置
    ///   - radii: 圆角大小
    func setRounding(rect: CGRect? = nil, corners: UIRectCorner, radii: CGSize, color: UIColor = .clear) {
        let roundRect = rect ?? bounds,
        path = UIBezierPath(roundedRect: roundRect, byRoundingCorners: corners, cornerRadii: radii),
        maskLayer = CAShapeLayer()
        
        maskLayer.frame = roundRect
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
//    func setColorRounding(rect: CGRect? = nil, corners: UIRectCorner, radii: CGSize, color : UIColor) {
//        let roundRect = rect ?? bounds,
//        path = UIBezierPath(roundedRect: roundRect, byRoundingCorners: corners, cornerRadii: radii),
//        maskLayer = CAShapeLayer()
//
//        maskLayer.frame = roundRect
//        layer.borderWidth = adapt(1)
//        layer.borderColor = color.cgColor
//        maskLayer.path = path.cgPath
//        layer.mask = maskLayer
//    }
    
}

// MARK: - snapshot
extension UIView {
    
    // 截图
    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func snapshotImage(afterUpdates: Bool) -> UIImage? {
        if !responds(to: #selector(drawHierarchy(in:afterScreenUpdates:))) {
            return snapshotImage()
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// MAARK: - subView
extension UIView {
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - rect
extension UIView {
    
    /// size
    var jr_size: CGSize {
        set {
            frame.size = newValue
        }
        get {
            return frame.size
        }
    }
    
    /// width
    var jr_width: CGFloat {
        set {
            frame.size.width = newValue
        }
        get {
            return frame.size.width
        }
    }
    
    /// height
    var jr_height: CGFloat {
        set {
            frame.size.height = newValue
        }
        
        get {
            return frame.size.height
        }
    }
    
    /// origin
    var jr_origin: CGPoint {
        set {
            frame.origin = newValue
        }
        
        get {
            return frame.origin
        }
    }
    
    /// x
    var jr_x: CGFloat {
        set {
            frame.origin.x = newValue
        }
        
        get {
            return frame.origin.x
        }
    }
    
    /// y
    var jr_y: CGFloat {
        set {
            frame.origin.y = newValue
        }
        
        get {
            return frame.origin.y
        }
    }
    
    var jr_maxY: CGFloat {
        return frame.maxY
    }
    
    var jr_maxX: CGFloat {
        return frame.maxX
    }
}
