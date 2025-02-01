//
//  Box.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/25.
//

import Foundation

@propertyWrapper
public final class Box<WrappedValue> {
    public var wrappedValue: WrappedValue
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}
