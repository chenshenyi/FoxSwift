//
//  Request+APIRouteValueProtocol.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import Vapor

/// Extension on Vapor's `Request` type providing convenient methods for parameter extraction.
extension Request {
    /// Retrieves and decodes a query parameter from the request.
    ///
    /// This method provides type-safe access to query parameters with proper error handling.
    ///
    /// ## Example
    /// ```swift
    /// let page: Int = try request.getQuery(at: "page")
    /// let search: String = try request.getQuery(at: "q")
    /// ```
    ///
    /// - Parameter key: The key of the query parameter to retrieve.
    /// - Returns: The decoded value of type `T`.
    /// - Throws: `RouteError.queryDecodingError` if the parameter cannot be decoded.
    public func getQuery<T: Decodable>(at key: String) throws(RouteError) -> T {
        do {
            return try query.get(at: key)
        } catch {
            throw .queryDecodingError(name: key, message: error.localizedDescription)
        }
    }

    /// Retrieves a path parameter from the request.
    ///
    /// This method provides type-safe access to path parameters with proper error handling.
    ///
    /// ## Example
    /// ```swift
    /// let userId: Int = try request.getParameter(name: "id")
    /// let username: String = try request.getParameter(name: "username")
    /// ```
    ///
    /// - Parameter name: The name of the path parameter to retrieve.
    /// - Returns: The converted value of type `T`.
    /// - Throws: `RouteError.missingPathParameter` if the parameter is missing or cannot be converted.
    public func getParameter<T: LosslessStringConvertible>(name: String) throws(RouteError) -> T {
        if let value = parameters.get(name, as: T.self) {
            return value
        } else {
            throw .missingPathParameter(name: name, type: T.self)
        }
    }

    /// Decodes the request body into a specified type.
    ///
    /// This method provides type-safe access to the request body with proper error handling.
    ///
    /// ## Example
    /// ```swift
    /// let user: User = try request.getBody()
    /// let post: Post = try request.getBody()
    /// ```
    ///
    /// - Returns: The decoded value of type `T`.
    /// - Throws: `RouteError.bodyDecodingError` if the body cannot be decoded.
    public func getBody<T: Decodable>() throws(RouteError) -> T {
        do {
            return try content.decode(T.self, as: .json)
        } catch {
            throw .bodyDecodingError(error.localizedDescription)
        }
    }
}
