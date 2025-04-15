//
//  ServiceProviderProtocol.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import Vapor

/// A protocol that defines the requirements for a route collection associated with a service.
///
/// This protocol combines Vapor's `RouteCollection` with a specific service type,
/// providing a standardized way to organize and register routes for a service.
///
/// ## Example
/// ```swift
/// struct UserRouteCollection: ServiceRouteCollection {
///     typealias Service = UserService
///
///     func boot(routes: any RoutesBuilder) throws {
///         let users = routes.grouped("users")
///         users.get(use: getUsers)
///         users.post(use: createUser)
///     }
/// }
/// ```
public protocol ServiceRouteCollection<Service>: RouteCollection {
    /// The associated service type that this route collection manages.
    associatedtype Service: ServiceProtocol

    /// Creates a new instance of the route collection.
    init()

    /// Registers all routes for this collection with the given route builder.
    /// - Parameter routes: The route builder to register routes with.
    /// - Throws: An error if route registration fails.
    func boot(routes: any Vapor.RoutesBuilder) throws
}
