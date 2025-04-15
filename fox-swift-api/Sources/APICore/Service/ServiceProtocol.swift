//
//  ServiceProtocol.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import Vapor

/// A protocol that defines the basic requirements for a service in the API.
///
/// Services are responsible for handling business logic and data processing
/// for specific features or resources in the application.
///
/// ## Example
/// ```swift
/// struct UserService: ServiceProtocol {
///     let request: Request
///
///     init(request: Request) {
///         self.request = request
///     }
///
///     func getUsers() async throws -> [User] {
///         // Implementation
///     }
/// }
/// ```
public protocol ServiceProtocol {
    /// The current HTTP request being handled by the service.
    var request: Vapor.Request { get }

    /// Creates a new instance of the service with the given request.
    /// - Parameter request: The HTTP request to be handled by the service.
    init(request: Vapor.Request)
}
