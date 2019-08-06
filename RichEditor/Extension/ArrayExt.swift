//
//  ArrayExt.swift
//  Record
//
//  Created by Maple on 2018/9/5.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import Foundation

extension Array where Element: AnyObject {
    /// 获取对象的索引 !!! 返回的是第一个元素 !!!
    ///
    /// - Parameter element: 目标对象
    /// - Returns: 索引
    func index(element: Element) -> Int? {
        for (index, temp) in lazy.enumerated() where temp === element {
            return index
        }
        return nil
    }
}

extension Array where Element: Equatable {
    /// 从数组中移除某个元素
    /// 移除数组中所有的该元素
    ///
    /// - Parameter element: 移除结果
    mutating func remove(element: Element) -> Bool {
        var elementCount = 0
        var result: Bool = false
        for (index, temp) in lazy.enumerated() where temp == element {
            remove(at: index - elementCount)
            elementCount += 1
            result = true
        }
        return result
    }
}

extension Array {
    /// 通过下标取元素, 不会出现越界
    ///
    /// - Parameter index: 索引
    /// - Returns: 元素
    func element(at index: Int) -> Element? {
        guard (startIndex..<endIndex).contains(index) else { return nil }
        return self[index]
    }
    
    
    /// 安全交换两个元素的位置
    ///
    /// - Parameters:
    ///   - index: first element
    ///   - another: second element
    /// - Returns: 交换结果
    mutating func safeSwap(from index: Int, to another: Int) -> Bool {
        guard index != another,
            startIndex..<endIndex ~= index,
            startIndex..<endIndex ~= another else { return false }
        swapAt(index, another)
        return true
    }
    
    mutating func safeInsertSwap(from index: Int, to another: Int) -> Bool {
        guard index != another else {
            return false
        }
        if index > another {
            var n = index - another
            n += n % 2 == 0 ? 1 : 0
            for x in another..<index {
                safeSwap(from: index, to: x)
            }
        }else {
            var n = another - index
            n += n % 2 == 0 ? 1 : 0
            for x in index..<another {
                safeSwap(from: index, to: (index + another - x))
            }
        }
        return true
    }
    
    /// 返回所有符合条件的元素的下标
    ///
    /// - Parameter predicate: 筛选条件
    /// - Returns: 符合条件的小标
    func allIndexs(where predicate: (Element) throws -> Bool) rethrows -> [Int]? {
        var indexs: [Int] = [ ]
        for (index, element) in lazy.enumerated() {
            if try predicate(element) {
                indexs.append(index)
            }
        }
        return indexs.isEmpty ? nil : indexs
    }
    
    /// 返回所有符合条件的元素
    ///
    /// - Parameter predicate: 筛选条件
    /// - Returns: 符合条件的索引
    func allElements(where predicate: (Element) throws -> Bool) rethrows -> [Element]? {
        var elements: [Element] = [ ]
        for element in self {
            if try predicate(element) {
                elements.append(element)
            }
        }
        return elements.isEmpty ? nil : elements
    }
    
    
}

// MARK: - json
extension Array {
    var json: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
