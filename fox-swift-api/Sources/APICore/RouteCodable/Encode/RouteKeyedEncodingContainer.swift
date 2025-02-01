//
//  RouteKeyedEncodingContainer.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/24.
//

import Foundation

struct RouteKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [any CodingKey]
    @Box var components: [String]

    init(components: Box<[String]>, codingPath: [any CodingKey] = []) {
        _components = components
        self.codingPath = codingPath
    }
    
    private mutating func encode(with key: Key) {
        codingPath.append(key)
        if !key.stringValue.hasPrefix("_") {
            components.append(key.stringValue)
        }
    }
    
    // MARK: - Nested Containers
    
     mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        encode(with: key)
        return KeyedEncodingContainer(RouteKeyedEncodingContainer<NestedKey>(
            components: _components, 
            codingPath: codingPath
        ))
    }
    
     mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        encode(with: key)
        return RouteUnkeyedEncodingContainer(components: _components, codingPath: codingPath)
    }
    
    // MARK: - Super Encoder
    
     mutating func superEncoder() -> any Encoder {
        Fatal.methodNotImplement()
    }
    
     mutating func superEncoder(forKey key: Key) -> any Encoder {
        Fatal.methodNotImplement()
    }

    // MARK: - Generic Encoding
    
     mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws(RouteEncodingError) {
        encode(with: key)
        let encoder = RouteEncoder(components: _components, codingPath: codingPath)
        try encoder.encode(with: value)
    }
    
    private mutating func encodeCustomStringConvertable<T: CustomStringConvertible>(_ value: T, forKey key: Key) throws(RouteEncodingError) {
        encode(with: key)
        components.append(value.description)
    }
    
     mutating func encodeNil(forKey key: Key) throws(RouteEncodingError) {}
    
    // MARK: - Encoding
    
     mutating func encode(_ value: UInt64, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: UInt32, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: UInt16, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: UInt8, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: UInt, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Int64, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Int32, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Int16, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Int8, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Int, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Float, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Double, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: String, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
    
     mutating func encode(_ value: Bool, forKey key: Key) throws(RouteEncodingError) {
        try encodeCustomStringConvertable(value, forKey: key)
    }
}
