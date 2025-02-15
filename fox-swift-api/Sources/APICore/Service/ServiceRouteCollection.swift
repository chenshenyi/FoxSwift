//
//  ServiceProviderProtocol.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import Vapor

public protocol ServiceRouteCollection<Service>: RouteCollection {
    associatedtype Service: ServiceProtocol
    init()
    func boot(routes: any Vapor.RoutesBuilder) throws
}
