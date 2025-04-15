//
//  User.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/14.
//

import CoreServices
import Fluent
import FoxSwiftAPI

import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class User: NamedSchemaModel, @unchecked Sendable {
    static let schemaName: SchemaName = .users

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "account")
    var account: String

    @Field(key: "bio")
    var bio: String?

    init() {}

    convenience init(_ dto: FS.User) {
        self.init()
        name = dto.name
        id = dto.id
        account = dto.account
        bio = dto.bio
    }

    func toDTO() -> FS.User {
        guard let id else { fatalError() }
        return .init(id: id, account: account, name: name, bio: bio)
    }
}
