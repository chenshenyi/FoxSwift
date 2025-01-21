//
//  ServerProtocol.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Foundation

/// - `scheme://hostname[:port]/basePath`
public protocol ServerProtocol {
    var scheme: String { get }
    var hostname: String { get }
    var port: UInt16? { get }
    var basePath: String? { get }
}

extension ServerProtocol {
    public var scheme: String { "http" }
    public var port: UInt16? { nil }
    public var basePath: String? { nil }
}

extension ServerProtocol {
    public var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = hostname
        if let port {
            urlComponents.port = Int(port)
        }
        if let basePath {
            urlComponents.paths = [basePath]
        }
        return urlComponents
    }
}
