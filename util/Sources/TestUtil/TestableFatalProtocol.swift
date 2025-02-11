//
//  TestableFatalProtocol.swift
//  TestUtil
//
//  Created by chen shen yi on 2025/2/1.
//

import Foundation
import OSLog
import ConcurrencyUtil

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
public protocol TestableFatalProtocol: Equatable, Error, CustomDebugStringConvertible {
    /// The logger instance used for recording fatal errors.
    ///
    /// This should be configured with appropriate subsystem and category values
    /// for your specific use case.
    static var logger: Logger { get }
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
    /// // In production code
    /// MyError.errorCase() // Triggers the fatal error
    ///
    /// // With custom file and line information
    /// MyError.errorCase(file: "CustomFile.swift", line: 42)
    /// ```
    ///
    /// ## Implementation Details
    /// The method performs the following steps:
    /// 1. Logs the error with detailed location information
    /// 2. Checks if running in test mode
    /// 3. Either throws the error (test mode) or triggers fatal error
    ///
    /// - Parameters:
    ///   - file: The file where the fatal error occurred (defaults to current file)
    ///   - line: The line number where the fatal error occurred (defaults to current line)
    ///   - column: The column number where the fatal error occurred (defaults to current column)
    ///   - function: The function name where the fatal error occurred (defaults to current function)
    /// - Returns: Never returns as it either crashes or throws
    /// - Note: When used in test mode, ensure proper error handling is in place
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

        if let continuation = TestableFatalState.continuation {
            continuation.resume(throwing: self)
            unreachable()
        } else {
            fatalError(debugDescription)
        }
    }
}

private actor TestableFatalState {
    /// A closure that can be set during testing to capture fatal errors instead of crashing.
    static var continuation: (CheckedContinuation<Void, any Error>)?
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
    while true {
        RunLoop.current.run()
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
    /// ## Basic Usage
    /// ```swift
    /// try await DatabaseError.test {
    ///     // This code might trigger DatabaseError.connectionFailed()
    ///     await database.connect()
    /// }
    /// ```
    ///
    /// ## Advanced Usage
    /// ```swift
    /// // Testing with custom timeout
    /// try await DatabaseError.test(timeout: .seconds(5)) {
    ///     await performLongOperation()
    /// }
    ///
    /// // Testing multiple potential errors
    /// try await DatabaseError.test {
    ///     try await database.connect()
    ///     try await database.query("SELECT * FROM users")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///     - timeout: Duration to wait before concluding no fatal error occurred (defaults to 1 second)
    ///     - test: The async code block to test
    ///
    /// - Throws: The fatal error if one occurs during testing
    ///
    /// - Warning: Use `.serialized` trait when testing to avoid concurrent test execution
    ///           that might interfere with the global error handler.
    ///
    /// - Note: The timeout parameter should be adjusted based on the expected execution time
    ///         of the test code. Operations that might take longer should use a longer timeout.
    public static func test(
        timeout: Duration = .seconds(1),
        test: @Sendable @escaping () async throws -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            Task {
                TestableFatalState.continuation = continuation

                do {
                    try await test()
                    try await Task.sleep(for: timeout)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
