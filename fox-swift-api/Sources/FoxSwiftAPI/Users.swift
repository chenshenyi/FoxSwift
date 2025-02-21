//
//  Users.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/13.
//

@preconcurrency import Papyrus
import APICore
import Vapor

extension FS {
    public struct User: Identifiable, CodableContent {
        public let id: UUID?
        public let account: String
        public var name: String
        public var bio: String?

        public init(id: UUID? = nil, account: String, name: String, bio: String? = nil) {
            self.id = id
            self.account = account
            self.name = name
            self.bio = bio
        }
    }

    @API
    @Mock
    @Service
    public protocol Users {
        @GET("/users")
        func getUsers(limit: Int) async throws -> [User]

        @PUT("/users/:id")
        func putUser(id: UUID, user: Body<User>) async throws -> User
    }
}

extension FS.UsersAPI: Sendable {}
