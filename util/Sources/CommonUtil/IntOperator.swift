//
//  IntOperator.swift
//  util
//
//  Created by chen shen yi on 2025/2/11.
//

import Foundation

/// Defines postfix increment operator `++`
postfix operator ++
/// Defines prefix increment operator `++`
prefix operator ++
/// Defines postfix decrement operator `--`
postfix operator --
/// Defines prefix decrement operator `--`
prefix operator --

/// Extends `Int` type with C-style increment and decrement operators
/// These operators will wrap around on overflow/underflow instead of trapping
public extension Int {
    /// Postfix increment operator
    ///
    /// Returns the original value, then increments the variable by 1.
    /// If the value overflows, it wraps around to the minimum value.
    ///
    /// ```swift
    /// var x = Int.max
    /// let y = x++ // y = Int.max, x = Int.min
    /// ```
    ///
    /// - Parameter value: The integer value to operate on
    /// - Returns: The value before incrementing
    @discardableResult
    static postfix func ++(_ value: inout Int) -> Int {
        let original = value
        value &+= 1
        return original
    }

    /// Prefix increment operator
    ///
    /// Increments the variable by 1, then returns the new value.
    /// If the value overflows, it wraps around to the minimum value.
    ///
    /// ```swift
    /// var x = Int.max
    /// let y = ++x // y = Int.min, x = Int.min
    /// ```
    ///
    /// - Parameter value: The integer value to operate on
    /// - Returns: The value after incrementing
    @discardableResult
    static prefix func ++(_ value: inout Int) -> Int {
        value &+= 1
        return value
    }

    /// Postfix decrement operator
    ///
    /// Returns the original value, then decrements the variable by 1.
    /// If the value underflows, it wraps around to the maximum value.
    ///
    /// ```swift
    /// var x = Int.min
    /// let y = x-- // y = Int.min, x = Int.max
    /// ```
    ///
    /// - Parameter value: The integer value to operate on
    /// - Returns: The value before decrementing
    @discardableResult
    static postfix func --(_ value: inout Int) -> Int {
        let original = value
        value &-= 1
        return original
    }

    /// Prefix decrement operator
    ///
    /// Decrements the variable by 1, then returns the new value.
    /// If the value underflows, it wraps around to the maximum value.
    ///
    /// ```swift
    /// var x = Int.min
    /// let y = --x // y = Int.max, x = Int.max
    /// ```
    ///
    /// - Parameter value: The integer value to operate on
    /// - Returns: The value after decrementing
    @discardableResult
    static prefix func --(_ value: inout Int) -> Int {
        value &-= 1
        return value
    }
}
