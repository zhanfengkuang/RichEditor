//
//  UIConfig.swift
//  Record
//
//  Created by Maple on 2018/8/30.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import UIKit

/// 屏幕bounds
let screenBounds = UIScreen.main.bounds
/// 屏宽
let screenWidth = screenBounds.width
/// 屏高
let screenHeight = screenBounds.height
/// 根据iPhone6适配比例
let screenWidthScale = screenWidth / 375
/// 状态栏高度
let statusBarHeight = UIApplication.shared.statusBarFrame.height
/// 导航栏高度
let topBarHeight = statusBarHeight + 44
/// 屏比
let screenScale = UIScreen.main.scale
/// 底部安全高度
let safeBottom = safeBottomFunc()
/// 底部tabBar高度
let bottomBarHeight = 49 + safeBottom
let safeTop = safeTopFunc()
/// 空格
let normalSpace: CGFloat = 20

/// 根据iPhone6适配
func adapt(_ value: CGFloat) -> CGFloat {
    return value * screenWidthScale
}

private func safeTopFunc() -> CGFloat {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    return 20
}

private func safeBottomFunc() -> CGFloat {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    return 0
}

func fontSafe(font: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: (font - 2) * screenWidthScale)
}

func fontSafeBold(font: CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: (font - 2) * screenWidthScale)
}


