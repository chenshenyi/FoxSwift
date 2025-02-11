//
//  TestConcurrenceSemaphore.swift
//  CommonUtilTest
//
//  Created by AI on 2025/2/11.
//

import Foundation
import Testing
import CommonUtil
@testable import ConcurrencyUtil

@Suite("Test Concurrence Semaphore")
struct ConcurrenceSemaphoreTests {
    
    // MARK: - Basic Tests
    
    @Test func testInitialization() async {
        let semaphore = Semaphore(value: 2)
        await semaphore.wait()  // Should succeed immediately
        await semaphore.wait()  // Should succeed immediately
        // Now count should be 0
    }
    
    @Test func testBasicWaitSignal() async throws {
        let startTime = Date.now
        let waitingDuration = Duration.seconds(1)
        let semaphore = Semaphore(value: 1)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Should succeed immediately
            await semaphore.wait()

            group.addTask {
                // Wait a bit to ensure the task is blocked
                try await Task.sleep(for: .seconds(1))
                
                // Signal should unblock the task
                await semaphore.signal()
            }

            // Create a task that will be blocked
            group.addTask {
                await semaphore.wait()  // This should block
                #expect(startTime.distance(to: .now) > TimeInterval(waitingDuration.components.seconds))
            }
            
            try await group.waitForAll()
        }
    }

    // MARK: - FIFO Order Tests
    
    @Test func testFIFOOrder() async throws {
        let semaphore = Semaphore(value: 1)
        let taskCount = 30
        
        try await withThrowingTaskGroup(of: Int.self) { group in
            // Start tasks that will wait
            for i in 0..<taskCount {
                group.addTask {
                    await semaphore.wait()
                    try await Task.sleep(for: .milliseconds(Int.random(in: 500...1000)))
                    await semaphore.signal()
                    return i
                }
                try await Task.sleep(for: .milliseconds(10))
            }

            var counter = 0
            for try await result in group {
                #expect(counter == result)
                counter++
            }
        }
    }
} 
