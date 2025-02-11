//
//  TestUIntOperator.swift
//  CommonUtilTest
//
//  Created by chen shen yi on 2025/2/11.
//

import Testing
@testable import CommonUtil

@Suite("UInt Operator")
struct UIntOperatorTests {
    @Test func testPrefixIncrement() async throws {
        var value: UInt = 0
        #expect(value++ == 0)
        #expect(value == 1)
    }

    @Test func testPostfixIncrement() async throws {
        var value: UInt = 0
        #expect(++value == 1)
        #expect(value == 1)
    }

    @Test func testPrefixDecrement() async throws {
        var value: UInt = 1
        #expect(value-- == 1)
        #expect(value == 0)
    }

    @Test func testPostfixDecrement() async throws {
        var value: UInt = 1
        #expect(--value == 0)
        #expect(value == 0)
    }
    
    @Test func testOverflowPostfixIncrement() async throws {
        var value = UInt.max
        value++
        #expect(value == 0)
    }

    @Test func testOverflowPrefixIncrement() async throws {
        var value = UInt.max
        ++value
        #expect(value == 0)
    }

    @Test func testOverflowPostfixDecrement() async throws {
        var value: UInt = 0
        value--
        #expect(value == .max)
    }

    @Test func testOverflowPrefixDecrement() async throws {
        var value: UInt = 0
        --value
        #expect(value == .max)
    }

    @Test func testMultipleIncrements() async throws {
        var value: UInt = 0
        value++
        value++
        ++value
        #expect(value == 3)
    }

    @Test func testMultipleDecrements() async throws {
        var value: UInt = 3
        value--
        value--
        --value
        #expect(value == 0)
    }

    @Test func testMixedOperations() async throws {
        var value: UInt = 0
        value++
        --value
        ++value
        value--
        #expect(value == 0)
    }
} 
