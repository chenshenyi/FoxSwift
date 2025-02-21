//
//  SchemaName.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/17.
//

import Foundation
import Fluent

enum SchemaName: String {
    case users
}

extension Database {
    func schema(_ schemaName: SchemaName, space: String? = nil) -> SchemaBuilder {
        schema(schemaName.rawValue, space: space)
    }
}

protocol NamedSchemaModel: Model {
    static var schemaName: SchemaName { get }
}

extension NamedSchemaModel {
    static var schema: String {
        schemaName.rawValue
    }
}
