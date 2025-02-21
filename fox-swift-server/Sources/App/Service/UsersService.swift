//
//  UsersService.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/16.
//

import Foundation
import Vapor
import FoxSwiftAPI
import PapyrusCore

struct UsersService: FS.UsersServiceProtocol {
    var request: Vapor.Request

    func getUsers(limit: Int) async throws -> [FoxSwiftAPI.FoxSwift.User] {
        let users = try await User.query(on: request.db).limit(10).all()
        return users.map { $0.toDTO() }
    }

    func putUser(id: UUID, user: Body<FoxSwiftAPI.FoxSwift.User>) async throws -> FoxSwiftAPI.FoxSwift.User {
        let user = User(user)
        user.id = id
        try await user.save(on: request.db)
        return user.toDTO()
    }
}
