//
//  RouteError.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation

public enum RouteError: Error, CustomDebugStringConvertible {
    case missingPathParameter(name: String, type: Any.Type)
    case queryDecodingError(name: String, message: String)
    case bodyDecodingError(String)
    case invalidPath(String)
    case unknown(String? = nil)

    var name: String {
        switch self {
        case .missingPathParameter: "Missing Path Parameter"
        case .queryDecodingError: "Query Decoding Error"
        case .bodyDecodingError: "Body Decoding Error"
        case .invalidPath: "Invalid Path"
        case .unknown: "Unknown Error"
        }
    }

    public var debugDescription: String {
        "[\(name)] \(associatedValueDescription)"
    }

    private var associatedValueDescription: String {
        switch self {
        case let .missingPathParameter(name: name, type: type):
            "Can't find \(type) type parameter named \(name)"

        case let .queryDecodingError(name: name, message: message):
            "Can't decode query '\(name)'\n \(message)"

        case let .bodyDecodingError(error):
            "Decode body error with \(error)"

        case let .invalidPath(path):
            "Invalid path \(path)"

        case let .unknown(error):
            if let error {
                "Unknown error with \(error)"
            } else {
                "Unknown"
            }
        }
    }
}
