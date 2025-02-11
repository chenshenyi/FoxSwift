//
//  File.swift
//  util
//
//  Created by chen shen yi on 2025/2/11.
//

import Foundation
import CommonUtil

/// A traditional semaphore implementation using Swift Concurrency
public actor Semaphore: Sendable {
    
    /// The current value of the semaphore
    private var count: UInt
    private let value: UInt
    private var waitingSequence: [CheckedContinuation<Void, Never>] = []
    
    /// Initialize a new semaphore
    /// - Parameter value: The initial value of the semaphore
    public init(value: UInt = 1) {
        self.count = value
        self.value = value
    }
    
    /// Wait for the semaphore
    public func wait() async {
        if count > 0 {
            count--
        } else {
            await withCheckedContinuation {
                waitingSequence.append($0)
            }
        }
    }

    /// Signal the semaphore
    /// - Returns: The new value of the semaphore
    @discardableResult
    public func signal() -> UInt {
        if waitingSequence.isEmpty {
            if count < value {
                return ++count
            } else {
                return value
            }
        } else {
            // When waking up a waiter, count remains the same (0)
            // because the resource is immediately consumed
            waitingSequence.removeFirst().resume()
            return count
        }
    }
}
