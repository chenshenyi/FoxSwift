//
//  EndPointProtocol.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Foundation

public protocol EndPointProtocol {
    associatedtype PathParameter: Sendable
    associatedtype Query: Codable, Sendable
    associatedtype RequestBody: Codable, Sendable
    associatedtype ResponseBody: Codable, Sendable
    associatedtype Error: Swift.Error, Codable, Sendable

    static func path(_ parameter: PathParameter) -> String
}

extension EndPointProtocol {
    public typealias Query = Empty
    public typealias RequestBody = Empty
    public typealias ResponseBody = Empty
    public typealias Error = URLError
}

public struct Empty: Codable, Sendable {}
