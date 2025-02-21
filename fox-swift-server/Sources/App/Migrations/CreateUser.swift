//
//  CreateUser.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/16.
//

import Fluent
import FoxSwiftAPI

struct CreateUser: AsyncMigration {
    static let usersSchema = "users"

    func prepare(on database: Database) async throws {
        try await database.schema(.users)
            .id()
            .field("name", .string, .required)
            .field("account", .string, .required)
            .field("bio", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(.users).delete()
    }
}
