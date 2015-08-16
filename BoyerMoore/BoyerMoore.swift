//
//  BoyerMoore.swift
//  BoyerMoore
//
//  Created by Marcin Krzyzanowski on 15/08/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

struct BoyerMoore {
    
    enum BoyerMooreError: ErrorType {
        case NotFound
    }
    
    private let data:[Int]
    
    init(data: [Int]) {
        self.data = data
    }
    
    /// If char does not occur in pat, then patlen;
    /// else patlen - j, where j is the maximum integer
    /// such that pat(j) = char
    func delta1(pat: [Int], char: Int) -> Int {
        var i = 0
        // skip the last one, doesn't matter.
        for (i = pat.count - 1; i > 0 && pat[i - 1] != char; i--) { /* noop */ }
        return pat.count - i
    }
    
    func search(pat: String) throws -> Range<Int> {
        return try search(pat.unicodeScalars.map { Int($0.value) })
    }
    
    func search(pat:[Int]) throws -> Range<Int> {
        guard pat.count > 0 else {
            return Range(start:0, end:pat.count)
        }
        
        var i = pat.count - 1
        var j = 0
        while (i < data.count) {
            for (j = pat.count - 1; j >= 0 && data[i] == pat[j]; --i, --j) { /* noop */ }
            if (j < 0) {
                return Range(start:i + 1, end:i + 1 + pat.count)
            }
            
            i = i + delta1(pat, char: data[i])
        }
        
        throw BoyerMooreError.NotFound
    }
}

extension BoyerMoore: StringLiteralConvertible {
    //MARK: StringLiteralConvertible
    
    init(stringLiteral value: String) {
        self.data = value.unicodeScalars.map { Int($0.value) }
    }
    
    typealias UnicodeScalarLiteralType = StringLiteralType
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
}