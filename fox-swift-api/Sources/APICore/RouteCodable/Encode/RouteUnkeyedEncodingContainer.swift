//
//  RouteUnkeyedEncodingContainer.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/27.
//

import Foundation

 struct RouteUnkeyedEncodingContainer: UnkeyedEncodingContainer {
     var codingPath: [any CodingKey]
     var count: Int = 0
    @Box var components: [String]
    
    init(components: Box<[String]>, codingPath: [any CodingKey] = []) {
        _components = components
        self.codingPath = codingPath
    }
    
    // MARK: - Nested Containers
    
     mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        count += 1
        return KeyedEncodingContainer(RouteKeyedEncodingContainer<NestedKey>(
            components: _components,
            codingPath: codingPath
        ))
    }
    
     mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        count += 1
        return RouteUnkeyedEncodingContainer(
            components: _components,
            codingPath: codingPath
        )
    }
    
    // MARK: - Super Encoder
    
     mutating func superEncoder() -> any Encoder {
        Fatal.methodNotImplement()
    }
    
    // MARK: - Generic Encoding
    
     mutating func encode<T>(_ value: T) throws(RouteEncodingError) where T : Encodable {
        count += 1
        let encoder = RouteEncoder(components: _components, codingPath: codingPath)
        try encoder.encode(with: value)
    }
    
    private mutating func encodeCustomStringConvertable<T: CustomStringConvertible>(_ value: T) throws(RouteEncodingError) {
        count += 1
        components.append(value.description)
    }
    
     mutating func encodeNil() throws(RouteEncodingError) {}
    
    // MARK: - Encoding
    
     mutating func encode(_ value: UInt64) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: UInt32) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: UInt16) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: UInt8) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: UInt) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Int64) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Int32) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Int16) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Int8) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Int) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Float) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Double) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: String) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
    
     mutating func encode(_ value: Bool) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value)
    }
}
