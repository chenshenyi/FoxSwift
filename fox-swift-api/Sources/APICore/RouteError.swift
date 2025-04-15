//
//  RouteError.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation

/// Represents errors that can occur during route handling in the API.
///
/// This enum provides specific error cases for common routing issues such as:
/// - Missing path parameters
/// - Query parameter decoding failures
/// - Request body decoding failures
public enum RouteError: Error, CustomDebugStringConvertible {
    /// Indicates that a required path parameter is missing or cannot be converted to the expected type.
    /// - Parameters:
    ///   - name: The name of the missing parameter
    ///   - type: The expected type of the parameter
    case missingPathParameter(name: String, type: Any.Type)

    /// Indicates that a query parameter could not be decoded properly.
    /// - Parameters:
    ///   - name: The name of the query parameter
    ///   - message: A detailed error message explaining the decoding failure
    case queryDecodingError(name: String, message: String)

    /// Indicates that the request body could not be decoded properly.
    /// - Parameter message: A detailed error message explaining the decoding failure
    case bodyDecodingError(String)

    /// The name of the error type.
    var name: String {
        switch self {
        case .missingPathParameter: "Missing Path Parameter"
        case .queryDecodingError: "Query Decoding Error"
        case .bodyDecodingError: "Body Decoding Error"
        }
    }

    /// A debug description of the error, including the error type and specific details.
    public var debugDescription: String {
        "[\(name)] \(associatedValueDescription)"
    }

    /// Generates a detailed description of the error's associated values.
    private var associatedValueDescription: String {
        switch self {
        case let .missingPathParameter(name: name, type: type):
            "Can't find \(type) type parameter named \(name)"

        case let .queryDecodingError(name: name, message: message):
            "Can't decode query '\(name)'\n \(message)"

        case let .bodyDecodingError(error):
            "Decode body error with \(error)"
        }
    }
}
