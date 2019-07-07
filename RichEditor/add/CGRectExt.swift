
//
//  CGRectExt.swift
//  Record
//
//  Created by Maple on 2019/5/5.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import Foundation

extension CGRect {
    
    func resetX(_ x: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: x, y: origin.y), size: size)
    }
    
    func addX(_ x: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: x + origin.x, y: origin.y), size: size)
    }
    
    func resetY(_ y: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: origin.x, y: y), size: size)
    }
    
    func addY(_ y: CGFloat) -> CGRect {
        return CGRect(origin: CGPoint(x: origin.x, y: y + origin.y), size: size)
    }
    
    func resetW(_ width: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: CGSize(width: width, height: size.height))
    }
    
    func addW(_ width: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: CGSize(width: width + self.width, height: size.height))
    }
    
    func resetH(_ height: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
    
    func addH(_ height: CGFloat) -> CGRect {
        return CGRect(origin: origin, size: CGSize(width: width, height: height + self.height))
    }
}
