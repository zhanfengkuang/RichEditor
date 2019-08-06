//
//  StringExt.swift
//  Record
//
//  Created by Maple on 2018/8/31.
//  Copyright © 2018年 TanKe. All rights reserved.
//

import Foundation

extension String {
    static let backName = NSLocalizedString("btn_back", comment: "")
    
    static let accountBackName = NSLocalizedString("account_btn_back", comment: "")
//    func tapString() ->  {
//        
//    }
    
    var intValue: Int? {
        return Int(self)
    }
    
    var doubleValue: Double? {
        return Double(self)
    }
}

// MARK: - unicode transformation format
extension StringProtocol {
    
    /// !!! 计算带有emoji 表情的长度时 要采用utf-16 才会准确 !!!
    var utf16Count: Int {
        return utf16.count
    }
}

// MARK: - 字符串截取
extension String {
    
    func labelStrings() -> [ (String, NSRange) ] {
        return subString("#", " ")
    }
    
    // !!! 字符串中存在表情时会导致不准确 !!!
    /// 截取两个字符之间的字符串
    // 搞了半天时间复杂度还是高 之后再看吧
    func subString(_ first: Character, _ second: Character) -> [ (String, NSRange) ] {
        
        let firstStrings = split(separator: first)
        var result: [ (String, NSRange) ] = [ ]
        
        for (index, firstItem) in firstStrings.enumerated() {
            var location: Int = hasPrefix(first.description) ? 1 : 0
            // 连个字符什么都没有的情况
            if firstItem.hasPrefix(second.description) { continue }
            let secondStrings = firstItem.split(separator: second, maxSplits: 1)
            if let string = secondStrings.first {
                for againIndex in firstStrings.indices {
                    if againIndex > 0 {
                        location += (firstStrings[againIndex - 1]).utf16Count + 1
                    }
                    if index == againIndex { break }
                }
                result.append( (String(string), NSRange(location: location, length: string.utf16Count)) )
            }
        }
        // 剔除不是以第一个字符开头的情况
        if !hasPrefix(first.description), !result.isEmpty { result.removeFirst() }
        return result
    }
    
    /// A string with the ' characters in it escaped.
    /// Used when passing a string into JavaScript, so the string is not completed too soon
    var escaped: String {
        let unicode = self.unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || // 39 == ' in ASCII
                char.value < 9 ||  // 9 == horizontal tab in ASCII
                (char.value > 9 && char.value < 32) // < 32 == special characters in ASCII
            {
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }
    
    //  匹配 字符串中 相同的字符  range 相同字符串的位置
    func ranges(of string: String) -> [Range<String.Index>] {
        var rangeArray = [Range<String.Index>]()
        var searchedRange: Range<String.Index>
        guard let sr = self.range(of: self) else {
            return rangeArray
        }
        searchedRange = sr
        
        var resultRange = self.range(of: string, options: [ ], range: searchedRange, locale: nil)
        while let range = resultRange {
            rangeArray.append(range)
            searchedRange = Range(uncheckedBounds: (range.upperBound, searchedRange.upperBound))
            resultRange = self.range(of: string, options: [ ], range: searchedRange, locale: nil)
        }
        return rangeArray
    }
    
    func nsranges(of string: String) -> [NSRange] {
        return ranges(of: string).map { (range) -> NSRange in
            self.nsrange(fromRange: range)
        }
    }
    
    func nsrange(fromRange range : Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

// MARK: - 格式校验
extension String {
    
    var withoutspace: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var digitString: String {
        let nonDigitSet = CharacterSet(charactersIn: "0123456789").inverted
        return withoutspace.components(separatedBy: nonDigitSet).joined()
    }
}

// MARK: - appending
extension String {
    func appendingPathComponent(_ string: String) -> String {
        return (self as NSString).appendingPathComponent(string)
    }
    
    func appendingPathExtension(_ string: String) -> String {
        return (self as NSString).appendingPathExtension(string) ?? self
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
}

// MARK: - size
extension String {
    /// 获取字符串的宽高
    func bounding(width containerSize: CGSize, font: CGFloat) -> CGSize {
        return bounding(width: containerSize, font: UIFont.systemFont(ofSize: font))
    }
    
    func bounding(width containerSize: CGSize, font: UIFont) -> CGSize {
        let attribute = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: count)
        attribute.addAttributes([.font: font], range: range)
        let layout = YYTextLayout(containerSize: containerSize, text: attribute)
        return layout?.textBoundingRect.size ?? .zero
    }

    // 不是太准确????
    func bounding(container size: CGSize, font: CGFloat, linespace: CGFloat = 0) -> CGSize {
        let attribute = NSMutableAttributedString(string: self),
        range = NSRange(location: 0, length: count),
        paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = linespace
        attribute.addAttributes([
            .font: UIFont.systemFont(ofSize: font),
            .paragraphStyle: paragraphStyle
            ], range: range)
        let rect = attribute.boundingRect(with: size, context: nil)
        return rect.size
    }
}

