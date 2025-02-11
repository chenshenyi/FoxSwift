//
//  TestableFatalTest.swift
//  test-util
//
//  Created by chen shen yi on 2025/2/1.
//

import Foundation
import Testing
import OSLog
@testable import TestUtil


enum Fatal: String {
    case first
    case second
}

extension Fatal: TestableFatalProtocol {
    static let logger: Logger = Logger(subsystem: "TestableFatal", category: "Test")

    var debugDescription: String {
        rawValue
    }
}

@Suite("Test Testable Fatal", .serialized)
struct FatalTest {
    @Test func testThrowFatal() async throws {
        await #expect(throws: Fatal.first) {
            try await Fatal.test {
                Fatal.first()
            }
        }
    }

    @Test func testAsync() async throws {
        let startTime = Date.now
        await #expect(throws: Fatal.second) {
            try await Fatal.test(timeout: .seconds(5)) {
                try await Task.sleep(for: .seconds(2))
                Fatal.second()
            }
        }
        #expect(Date.now.timeIntervalSince(startTime) > 2)
    }
    
    enum SomeError: Error {
        case some
    }
    @Test func testThrowingOtherError() async throws {
        await #expect(throws: SomeError.some) {
            try await Fatal.test {
                throw SomeError.some
            }
        }
    }

    @Test
    func testNotThrowFatal() async throws {
        try await Fatal.test {
            print("not throwing")
        }
    }
}
