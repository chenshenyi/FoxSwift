//
//  Request+APIRouteValueProtocol.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import Vapor

extension Request {
    public func getQuery<T: Decodable>(at key: String) throws(RouteError) -> T {
        do {
            return try query.get(at: key)
        } catch {
            throw .queryDecodingError(name: key, message: error.localizedDescription)
        }
    }

    public func getParameter<T: LosslessStringConvertible>(name: String) throws(RouteError) -> T {
        if let value = parameters.get(name, as: T.self) {
            return value
        } else {
            throw .missingPathParameter(name: name, type: T.self)
        }
    }

    public func getBody<T: Decodable>() throws(RouteError) -> T {
        do {
            return try content.decode(T.self, as: .json)
        } catch {
            throw .bodyDecodingError(error.localizedDescription)
        }
    }
}
