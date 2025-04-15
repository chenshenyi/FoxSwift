//
//  UsersTests.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/16.
//

import Fluent
import FoxSwiftAPI
import Papyrus
import Testing
import VaporTesting

@testable import App

extension FS.UsersAPI: TestableAPI {}

extension FS.User: RandomGeneratable {
    static var rand: FoxSwift.User {
        .init(
            id: .rand,
            account: "account\(Int.random())",
            name: "name\(Int.random())",
            bio: "bio\(Int.random())"
        )
    }
}

@Suite("Users Tests", .serialized)
struct UsersTests {
    @Test func testPutUser() async throws {
        try await test(api: FS.UsersAPI.self) { app, api in
            let (uuid, user): (UUID, FS.User) = rand()
            let res = try await api.putUser(id: uuid, user: user)
            #expect(res.name == user.name)
            #expect(res.account == user.account)

            let model = try await User.find(uuid, on: app.db)
            #expect(model?.name == res.name)
            #expect(model?.account == res.account)
        }
    }

    @Test func testGetUsers() async throws {
        try await test(api: FS.UsersAPI.self) { app, api in
            let list: [(UUID, FS.User)] = rands(amount: 10)

            try await withThrowingTaskGroup(of: Void.self) { group in
                for (id, user) in list {
                    group.addTask {
                        _ = try await api.putUser(id: id, user: user)
                    }
                }
                try await group.waitForAll()
            }

            let res = try await api.getUsers(limit: 10)

            #expect(Set(res.map(\.name)) == Set(list.map(\.1.name)))
            #expect(Set(res.map(\.account)) == Set(list.map(\.1.account)))
        }
    }

    @Test func testGetUser() async throws {
        try await test(api: FS.UsersAPI.self) { app, api in
            let (uuid, user): (UUID, FS.User) = rand()
            _ = try await api.putUser(id: uuid, user: user)
            let res = try await api.getUser(id: uuid)
            #expect(res.name == user.name)
            #expect(res.account == user.account)
            #expect(res.bio == user.bio)
        }
    }
}
