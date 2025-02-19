//
//  FoxSwift.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Papyrus
import Foundation
import Vapor

/// A type alias for the `FoxSwift` namespace.
public typealias FS = FoxSwift

/// The main namespace for the FoxSwift API.
///
/// This enum serves as a namespace for API-related types, constants, and utilities.
/// It provides centralized access to API configuration and common types used throughout the application.
public enum FoxSwift {
    /// The current version of the API.
    public static let apiVersion: Int = 1
    
    /// The base path for all API endpoints.
    ///
    /// This path includes the version number and is used as a prefix for all API routes.
    /// For example: "/api/v1"
    public static var basePath: String {
        "/api/v\(apiVersion)"
    }

    /// A type constraint for content types used in the API.
    ///
    /// This typealias combines several protocols to ensure that content types are:
    /// - Compatible with Vapor's content system
    /// - Codable for JSON serialization
    /// - Equatable for comparison
    /// - Sendable for concurrent operations
    public typealias CodableContent = Vapor.Content&Codable&Equatable&Sendable

    /// Represents errors that can occur during API operations.
    ///
    /// This enum provides specific error cases for common API-related issues.
    public enum APIError: Swift.Error, Codable {
        /// Indicates that a required query parameter is missing.
        /// - Parameters:
        ///   - queryName: The name of the missing query parameter.
        ///   - msg: A detailed error message.
        case missingQuery(queryName: String, msg: String)
        
        /// Indicates that a required path parameter is missing.
        /// - Parameter name: The name of the missing path parameter.
        case missingPathParameter(String)
        
        /// Indicates that the request body could not be decoded.
        /// - Parameter msg: A detailed error message.
        case requestBodyDecodingError(msg: String)
        
        /// Indicates an unknown error occurred.
        case unknown
    }
}
