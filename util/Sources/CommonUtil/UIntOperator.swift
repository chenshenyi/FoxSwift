//
//  UIntOperator.swift
//  util
//
//  Created by chen shen yi on 2025/2/11.
//

import Foundation

/// Extends `UInt` type with C-style increment and decrement operators
/// These operators will wrap around on overflow/underflow instead of trapping
public extension UInt {
    /// Postfix increment operator
    ///
    /// Returns the original value, then increments the variable by 1.
    /// If the value overflows, it wraps around to zero.
    ///
    /// ```swift
    /// var x = UInt.max
    /// let y = x++ // y = UInt.max, x = 0
    /// ```
    ///
    /// - Parameter value: The unsigned integer value to operate on
    /// - Returns: The value before incrementing
    @discardableResult
    static postfix func ++(_ value: inout UInt) -> UInt {
        let original = value
        value &+= 1
        return original
    }

    /// Prefix increment operator
    ///
    /// Increments the variable by 1, then returns the new value.
    /// If the value overflows, it wraps around to zero.
    ///
    /// ```swift
    /// var x = UInt.max
    /// let y = ++x // y = 0, x = 0
    /// ```
    ///
    /// - Parameter value: The unsigned integer value to operate on
    /// - Returns: The value after incrementing
    @discardableResult
    static prefix func ++(_ value: inout UInt) -> UInt {
        value &+= 1
        return value
    }

    /// Postfix decrement operator
    ///
    /// Returns the original value, then decrements the variable by 1.
    /// If the value underflows, it wraps around to the maximum value.
    ///
    /// ```swift
    /// var x: UInt = 0
    /// let y = x-- // y = 0, x = UInt.max
    /// ```
    ///
    /// - Parameter value: The unsigned integer value to operate on
    /// - Returns: The value before decrementing
    @discardableResult
    static postfix func --(_ value: inout UInt) -> UInt {
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
    /// var x: UInt = 0
    /// let y = --x // y = UInt.max, x = UInt.max
    /// ```
    ///
    /// - Parameter value: The unsigned integer value to operate on
    /// - Returns: The value after decrementing
    @discardableResult
    static prefix func --(_ value: inout UInt) -> UInt {
        value &-= 1
        return value
    }
}
