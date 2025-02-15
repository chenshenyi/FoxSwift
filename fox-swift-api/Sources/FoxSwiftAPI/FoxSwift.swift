//
//  FoxSwift.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Papyrus
import Foundation
import Vapor

public typealias FS = FoxSwift

public enum FoxSwift {
    public static let apiVersion: Int = 1
    public static var basePath: String {
        "/api/v\(apiVersion)"
    }

    public typealias CodableContent = Vapor.Content&Codable&Equatable&Sendable

    public enum APIError: Swift.Error, Codable {
        case missingQuery(queryName: String, msg: String)
        case missingPathParameter(String)
        case requestBodyDecodingError(msg: String)
        case unknown
    }

    public enum ResponseResult<Payload: Codable>: Codable {
        case success(Payload)
        case error(APIError)

        public func throwing() throws(APIError) -> Payload {
            switch self {
            case let .success(payload): payload
            case let .error(error): throw error
            }
        }
    }
}
