//
//  FoxSwift.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Papyrus
import Foundation

public typealias FS = FoxSwift

public enum FoxSwift {
    public static let apiVersion: Int = 1
    public static var basePath: String {
        "/api/v\(apiVersion)"
    }

    public typealias DTO = Codable&Sendable

    public enum Error: Swift.Error, DTO {
        case missingQuery(queryName: String, msg: String)
        case missingPathParameter(String)
        case requestBodyDecodingError(msg: String)
        case unknown
    }

    public enum ResponseResult<Payload: DTO>: DTO {
        case success(Payload)
        case error(Error)

        public func throwing() throws(Error) -> Payload {
            switch self {
            case let .success(payload): payload
            case let .error(error): throw error
            }
        }
    }
}
