//
//  AppUtil.swift
//  Record
//
//  Created by Maple on 2018/9/14.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import Foundation

struct AppUtil {
    /// 最顶部的window
    static var topWindow: UIWindow? {
        var window: UIWindow?
        for item in UIApplication.shared.windows {
            // 键盘window
            if NSStringFromClass(item.classForCoder) == "UIRemoteKeyboardWindow" {
                window = item
            }
        }
        return window ?? keyWindow
    }
    
    /// keyWindow
    static var keyWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    /// key window view controller
    static var rootViewController: UIViewController? {
        set {
            UIApplication.shared.keyWindow?.rootViewController = newValue
        }
        get {
            return UIApplication.shared.keyWindow?.rootViewController
            
        }
    }
    
    /// 获取当前显示的view controller
    ///
    /// - Returns: view controller
    static func fetchCurrentVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.keyWindow,
        windows = UIApplication.shared.windows
        guard let rootVC = keyWindow?.rootViewController ?? windows.first?.rootViewController
            else { return nil }
        return currentVC(rootVC)
    } 
    
    private static func currentVC(_ vc: UIViewController) -> UIViewController? {
        if let presentVC = vc.presentedViewController {
            return currentVC(presentVC)
        }
        
        if let rootVC = vc as? UITabBarController,
            let selectedVC = rootVC.selectedViewController {
            return currentVC(selectedVC)
        }
        
        if let rootVC = vc as? UINavigationController,
            let visibleVC = rootVC.visibleViewController {
            return visibleVC
        }
        return vc
    }
}

extension AppUtil {
//    static func systemVersion
    
}

// MARK: - status
extension AppUtil {
    
}
