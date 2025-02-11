//
//  File.swift
//  util
//
//  Created by chen shen yi on 2025/2/11.
//

import Testing
@testable import CommonUtil

@Suite("Int Operator")
struct IntOperatorTests {
    @Test func testPrefixIncrement() async throws {
        var value = 0
        #expect(value++ == 0)
        #expect(value == 1)
    }

    @Test func testPostfixIncrement() async throws {
        var value = 0
        #expect(++value == 1)
        #expect(value == 1)
    }

    @Test func testPrefixDecrement() async throws {
        var value = 1
        #expect(value-- == 1)
        #expect(value == 0)
    }

    @Test func testPostfixDecrement() async throws {
        var value = 1
        #expect(--value == 0)
        #expect(value == 0)
    }
    
    @Test func testOverflowPostfixIncrement() async throws {
        var value = Int.max
        value++
        #expect(value == .min)
    }

    @Test func testOverflowPrefixIncrement() async throws {
        var value = Int.max
        ++value
        #expect(value == .min)
    }

    @Test func testOverflowPostfixDecrement() async throws {
        var value = Int.min
        value--
        #expect(value == .max)
    }

    @Test func testOverflowPrefixDecrement() async throws {
        var value = Int.min
        --value
        #expect(value == .max)
    }

    @Test func testMultipleIncrements() async throws {
        var value = 0
        value++
        value++
        ++value
        #expect(value == 3)
    }

    @Test func testMultipleDecrements() async throws {
        var value = 3
        value--
        value--
        --value
        #expect(value == 0)
    }

    @Test func testMixedOperations() async throws {
        var value = 0
        value++
        --value
        ++value
        value--
        #expect(value == 0)
    }
}
