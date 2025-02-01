//
//  TestableFatalProtocol.swift
//  TestableFatal
//
//  Created by chen shen yi on 2025/2/1.
//

import Foundation
import OSLog

public protocol TestableFatalProtocol: Equatable, Error, CustomDebugStringConvertible {
    static var logger: Logger { get }
    nonisolated(unsafe) static var testableFatal: ((Self) -> Void)? { get set }
}

extension TestableFatalProtocol {
    public func callAsFunction(
        file: StaticString = #fileID,
        line: UInt = #line,
        column: UInt = #column,
        function: StaticString = #function
    ) -> Never {
        Self.logger.log(
            level: .fault,
            """
            \(file):\(line):\(column)
            \(function)
            \(debugDescription)
            """
        )

        if let testableFatal = Self.testableFatal {
            testableFatal(self)
            unreachable()
        } else {
            fatalError(self.debugDescription)
        }
    }

    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while true
    }
}

extension TestableFatalProtocol {
    /// - Parameters:
    ///     - timeout: you should assign timeout duration to limit the time when this test not throwing fatal error
    ///
    /// - WARNING: Test fatal use unsafe static properties to inject fatal function, so you should use `.serialized` trait when testing.
    public static func test(timeout: Duration = .seconds(1),
                     test: @Sendable @escaping () async throws -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            Task {
                testableFatal = { fatal in
                    continuation.resume(throwing: fatal)
                }

                do {
                    try await test()
                    try await Task.sleep(for: timeout)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        testableFatal = nil
    }
}
