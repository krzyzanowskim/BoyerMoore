//
//  BoyerMoore.swift
//  BoyerMoore
//
//  Created by Marcin Krzyzanowski on 15/08/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

struct BoyerMoore {
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
    
    func suffixes(pat:[Int]) -> [Int] {
        var suff = [Int](count: pat.count, repeatedValue: 0)

        suff[pat.count - 1] = pat.count
        var g = pat.count - 1
        var f = 0
        for (var i = pat.count - 2; i >= 0; --i) {
            if (i > g && suff[i + pat.count - 1 - f] < i - g) {
                suff[i] = suff[i + pat.count - 1 - f]
            } else {
                if i < g {
                    g = i
                }
                f = i
                while (g >= 0 && pat[g] == pat[g + pat.count - 1 - f]) {
                    --g
                }
                suff[i] = f - g
            }
        }
        return suff
    }
    
    func delta2(j: Int) -> Int {
        return 0
    }
    
    enum BoyerMooreError: ErrorType {
        case NotFound
    }
    
    func search(pat:[Int]) throws -> Range<Int> {
        guard pat.count > 0 else {
            return Range(start:0, end:pat.count)
        }
        
        var i = pat.count - 1
        while (i < data.count) {
            var j = pat.count - 1
            while (j >= 0 && data[i] == pat[j]) {
                --i
                --j
            }
            if (j < 0) {
                return Range(start:i + 1, end:i + 1 + pat.count)
            }
            
            i = i + max(delta1(pat, char: data[i]), delta2(j))
        }
        
        throw BoyerMooreError.NotFound
    }
}