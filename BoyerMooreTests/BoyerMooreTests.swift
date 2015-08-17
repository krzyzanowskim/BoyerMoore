//
//  BoyerMooreTests.swift
//  BoyerMooreTests
//
//  Created by Marcin Krzyzanowski on 15/08/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import XCTest
@testable import BoyerMoore

class BoyerMooreTests: XCTestCase {
    
    let data = [72,69,82,69,32,73,83,32,  65,32,83,73 ,77,80,76,69,32,69,88,65,77,80,76,69]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDelta1() {
        let bm = BoyerMoore(data: data)
        let pat1 = [69,88,65,77,80,76,69]
        XCTAssert(bm.delta1(pat1, char: 65) == 4)
        XCTAssert(bm.delta1(pat1, char: 69) == 6)
        XCTAssert(bm.delta1(pat1, char: 76) == 1)
        XCTAssert(bm.delta1(pat1, char: 77) == 3)
        XCTAssert(bm.delta1(pat1, char: 80) == 2)
        XCTAssert(bm.delta1(pat1, char: 88) == 5)
        XCTAssert(bm.delta1(pat1, char: 00) == 7)
        
        let pat2 = [59,88,65,77,69,69,69]
        XCTAssert(bm.delta1(pat2, char: 69) == 1)
        XCTAssert(bm.delta1(pat2, char: 59) == 6)
        
        let pat3 = [59,69,65,77,69,00,00]
        XCTAssert(bm.delta1(pat3, char: 59) == 6)
        XCTAssert(bm.delta1(pat3, char: 69) == 2)
        XCTAssert(bm.delta1(pat3, char: 00) == 1)
        
        let pat4 = [69,79,65,77,89,00,00]
        XCTAssert(bm.delta1(pat4, char: 69) == 6)
        
        let pat5 = [00,79,65,77,89,00,01]
        XCTAssert(bm.delta1(pat5, char: 00) == 1)
        XCTAssert(bm.delta1(pat5, char: 01) == 7)
    }
    
    func testSearch() {
        let bm = BoyerMoore(data: data)
        XCTAssertNoThrowValidateValue(try bm.search([65,32,83,73])) { $0.startIndex == 8 }
        XCTAssertThrow(try bm.search([65,32,183,73]))
        XCTAssertNoThrowValidateValue(try bm.search([72])) { $0.startIndex == 0 }
    }
    
    func testSearchString() {
        let bm = BoyerMoore(stringLiteral: "HERE IS A SIMPLE EXAMPLE")
        XCTAssertNoThrowValidateValue(try bm.search("A SI")) { $0.startIndex == 8 }
        XCTAssertThrow(try bm.search("AXSI"))
        XCTAssertNoThrowValidateValue(try bm.search("H")) { $0.startIndex == 0 }
    }

    
    func testPerformanceBoyerMoore() {
        let loremText = "Maecenas sed diam eget risus varius blandit sit amet non magna. Cras mattis consectetur purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Cras mattis consectetur purus sit amet fermentum. Maecenas faucibus mollis interdum."
        let loremData = loremText.unicodeScalars.map { Int($0.value) }
        self.measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) { () -> Void in
            for _ in 0...9999 {
                try! BoyerMoore(data: loremData).search([105, 109, 101, 110, 116, 117, 109, 32, 110, 105, 98, 104, 44, 32])
            }
        }
    }
    
    func testPerformanceNSData() {
        let loremText = "Maecenas sed diam eget risus varius blandit sit amet non magna. Cras mattis consectetur purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Cras mattis consectetur purus sit amet fermentum. Maecenas faucibus mollis interdum."
        let loremData = loremText.unicodeScalars.map { Int($0.value) }
        let data = NSData(bytes: loremData, length: loremData.count)
        let searchData = NSData(bytes: [65,32,83,73], length: 4)
        self.measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) { () -> Void in
            for _ in 0...9999 {
                data.rangeOfData(searchData, options: NSDataSearchOptions(rawValue: 0), range: NSRange(location: 0, length: data.length))
            }
        }
    }
    
    func testPerformanceCFData() {
        let loremText = "Maecenas sed diam eget risus varius blandit sit amet non magna. Cras mattis consectetur purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Cras mattis consectetur purus sit amet fermentum. Maecenas faucibus mollis interdum."
        let loremData = loremText.unicodeScalars.map { UInt8($0.value) }
        let data = CFDataCreate(nil, loremData, loremData.count)
        let searchData = CFDataCreate(nil, [65,32,83,73], 4)
        
        self.measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) { () -> Void in
            for _ in 0...9999 {
                CFDataFind(data, searchData, CFRangeMake(0, loremData.count), CFDataSearchFlags(rawValue: 0))
            }
        }
    }

    func testPerformanceString() {
        let loremText = "Maecenas sed diam eget risus varius blandit sit amet non magna. Cras mattis consectetur purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Cras mattis consectetur purus sit amet fermentum. Maecenas faucibus mollis interdum."
        self.measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) { () -> Void in
            for _ in 0...9999 {
                /// map() is so slow
                try! BoyerMoore(stringLiteral: loremText).search("imentum nibh,")
            }
        }
    }

    func testPerformanceFoundationNSString() {
        let loremText = "Maecenas sed diam eget risus varius blandit sit amet non magna. Cras mattis consectetur purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Cras mattis consectetur purus sit amet fermentum. Maecenas faucibus mollis interdum."
        self.measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) { () -> Void in
            for _ in 0...9999 {
                loremText.rangeOfString("imentum nibh,")
            }
        }
    }
    
    func testLong() {
          let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. asfubouboafogsdgouyvegasosihfsfhi Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        let pattern: BoyerMoore = "asfubouboafogsdgouyvegasosihfsfhi"
        
        XCTAssertNoThrowValidateValue(try pattern.search(text)) { _ in true }
        
    }

}



private func XCTAssertNoThrowValidateValue<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ validator: (T) -> Bool) {
    do {
        let result = try expression()
        XCTAssert(validator(result), "Value validation failed - \(message)", file: file, line: line)
    } catch let error {
        XCTFail("Caught error: \(error) - \(message)", file: file, line: line)
    }
}

private func XCTAssertThrow<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    do {
        try expression()
        XCTFail(message, file: file, line: line)
    } catch _ {
        XCTAssert(true)
    }
}
