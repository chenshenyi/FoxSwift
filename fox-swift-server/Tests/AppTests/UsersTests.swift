//
//  UsersTests.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/16.
//

@testable import App
import VaporTesting
import Testing
import Fluent
import FoxSwiftAPI
import Papyrus

protocol TestableAPI {
    init(provider: Provider)
}

func test<T: TestableAPI>(api: T.Type = T.self, _ block: (Application, T) async throws -> Void) async throws {
    let app = try await Application.make(.testing)


    let api = T(provider: .vaporTestingProvider(app: app))
    do {
        try await configure(app)
        try await app.autoMigrate()
        try await block(app, api)
    } catch {
        try await app.autoRevert()
        try await app.asyncShutdown()
        throw error
    }
    try await app.autoRevert()
    try await app.asyncShutdown()
}

extension FS.UsersAPI: TestableAPI {}

@Suite("Users Tests", .serialized)
struct UsersTests {
    @Test func testPutUser() async throws {
        try await test(api: FS.UsersAPI.self) { app, api in
            let uuid = UUID()
            let user = FS.User(account: "foxswift", name: "testing")
            let res = try await api.putUser(id: uuid, user: user)
            #expect(res.name == user.name)
            #expect(res.account == user.account)
            let model = try await User.query(on: app.db).filter(.id, .equal, uuid).first()
            #expect(model?.name == res.name)
            #expect(model?.account == res.account)
        }
    }

    @Test func testGetUsers() async throws {
        try await test(api: FS.UsersAPI.self) { app, api in
            let users = (0..<10).map { i in
                FS.User(account: "account\(i)", name: "name\(i)")
            }
            try await withThrowingTaskGroup(of: FS.User.self) { group in
                users.forEach { user in
                    group.addTask {
                        try await api.putUser(id: .generateRandom(), user: user)
                    }
                }
                try await group.waitForAll()
            }

            let res = try await api.getUsers(limit: 10)
            #expect(Set(res.map(\.name)) == Set(users.map(\.name)))
            #expect(Set(res.map(\.account)) == Set(users.map(\.account)))
        }
    }
}
