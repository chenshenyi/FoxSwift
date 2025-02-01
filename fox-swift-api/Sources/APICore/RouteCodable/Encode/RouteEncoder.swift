//
//  RouteEncoder.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/24.
//

import Foundation

public enum RouteEncodingError: Error {
    case unknown(Error)
}

public struct RouteEncoder: Encoder {
    @Box var components: [String]
    
    public var codingPath: [any CodingKey] = []
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    public init() {
        components = []
    }
    
    @discardableResult
    public func encode<T: Encodable>(with value: T) throws(RouteEncodingError) -> String {
        do {
            try value.encode(to: self)
        } catch let error as RouteEncodingError {
            throw error
        } catch {
            throw .unknown(error)
        }
        
        let path = components.joined(separator: "/")
        return "/\(path)"
    }

    package init(components: Box<[String]>, codingPath: [any CodingKey]) {
        _components = components
    }

    // MARK: - Encoder
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(RouteKeyedEncodingContainer(components: _components, codingPath: codingPath))
    }

    public func unkeyedContainer() -> any UnkeyedEncodingContainer {
        RouteUnkeyedEncodingContainer(components: _components, codingPath: codingPath)
    }
    
    public func singleValueContainer() -> any SingleValueEncodingContainer {
        RouteSingleValueEncodingContainer(components: _components, codingPath: codingPath)
    }
}
