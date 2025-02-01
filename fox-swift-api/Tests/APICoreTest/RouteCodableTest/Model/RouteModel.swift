//
//  RouteModel.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/28.
//

import Foundation

enum TestRoute: Codable, Equatable {
    case home
    case id(Int = 3)
    case float(Float)
    case bool(Bool)
    case nested(NestedRoute?)
    case parameterName(name: String)
    case twoPara(id: Int, userId: String)
    case array([Int])
}

enum NestedRoute: Codable, Equatable {
    case foo
}

struct StructureRoute: Codable, Equatable {
    var name: String
    var id: Int
}
