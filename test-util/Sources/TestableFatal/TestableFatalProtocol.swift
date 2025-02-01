//
//  TestableFatalProtocol.swift
//  TestableFatal
//
//  Created by chen shen yi on 2025/2/1.
//

import Foundation
import OSLog

/// A protocol that enables testable fatal errors in Swift.
///
/// This protocol provides a way to test code paths that would normally result in a fatal error,
/// making it possible to verify error handling in test scenarios.
///
/// ## Overview
/// `TestableFatalProtocol` allows you to:
/// - Create testable fatal errors that can be caught in tests
/// - Log fatal errors with detailed information
/// - Maintain production behavior while enabling test-time error catching
///
/// ## Example
/// ```swift
/// enum DatabaseError: TestableFatalProtocol {
///     static let logger = Logger(subsystem: "com.example.app", category: "Database")
///     var debugDescription: String { "Database connection failed" }
///
///     case connectionFailed
/// }
///
/// // In production code
/// func connect() {
///     guard isConnected else {
///         DatabaseError.connectionFailed() // This will cause a fatal error
///     }
/// }
///
/// // In test code
/// try await DatabaseError.test {
///     connect() // This will throw instead of causing a fatal error
/// }
/// ```
///
/// - Warning: This protocol uses unsafe static properties for testing purposes.
///            Always use the `.serialized` trait when running tests.
public protocol TestableFatalProtocol: Equatable, Error, CustomDebugStringConvertible {
    /// The logger instance used for recording fatal errors.
    ///
    /// This should be configured with appropriate subsystem and category values
    /// for your specific use case.
    static var logger: Logger { get }

    /// A closure that can be set during testing to capture fatal errors instead of crashing.
    ///
    /// This property is deliberately marked as `nonisolated(unsafe)` to match the behavior of `fatalError`,
    /// which can be called from any thread. Using an actor or thread-confined approach would create
    /// inconsistencies with real fatal error behavior.
    ///
    /// - Important: This property should only be modified through the `test` method.
    ///              Direct modification is unsafe and may lead to undefined behavior.
    ///
    /// - Note: The unsafe nature of this property is necessary to accurately simulate fatal errors,
    ///         which can occur on any thread. The `test` method provides a safe interface for testing.
    nonisolated(unsafe) static var testableFatal: ((Self) -> Void)? { get set }
}

extension TestableFatalProtocol {
    /// Triggers a fatal error with detailed logging information.
    ///
    /// This method provides two behaviors:
    /// - In production: Triggers a fatal error with detailed logging
    /// - In tests: Throws an error that can be caught by the test framework
    ///
    /// ## Usage
    /// ```swift
    /// MyError.errorCase() // Triggers the fatal error
    /// ```
    ///
    /// - Parameters:
    ///   - file: The file where the fatal error occurred
    ///   - line: The line number where the fatal error occurred
    ///   - column: The column number where the fatal error occurred
    ///   - function: The function name where the fatal error occurred
    /// - Returns: Never returns as it either crashes or throws
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

    /// A function that will never return, used to prevent code from continuing execution
    /// after a fatal error has been handled in test mode.
    ///
    /// This implementation uses `RunLoop` with a specific mode to:
    /// 1. Keep the thread alive until the error is properly thrown
    /// 2. Minimize resource usage by only processing the minimum required events
    /// 3. Avoid interfering with other `RunLoop` observers
    ///
    /// - Note: While this keeps the thread alive, the error will already have been
    ///         captured by the test handler before this is called.
    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while true
    }
}

extension TestableFatalProtocol {
    /// Tests a block of code that might trigger a fatal error.
    ///
    /// This method provides a safe way to test code that might trigger fatal errors by:
    /// 1. Temporarily installing a handler to capture fatal errors
    /// 2. Executing the test code
    /// 3. Waiting for either a fatal error or timeout
    /// 4. Cleaning up the handler
    ///
    /// ## Thread Safety
    /// While the underlying `testableFatal` property is unsafe and thread-unrestricted
    /// (to match `fatalError` behavior), this method provides a safe interface for testing.
    ///
    /// ## Example
    /// ```swift
    /// try await DatabaseError.test {
    ///     // This code might trigger DatabaseError.connectionFailed()
    ///     await database.connect()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///     - timeout: Duration to wait before concluding no fatal error occurred
    ///     - test: The async code block to test
    ///
    /// - Throws: The fatal error if one occurs during testing
    ///
    /// - Warning: Use `.serialized` trait when testing to avoid concurrent test execution
    ///           that might interfere with the global error handler.
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
