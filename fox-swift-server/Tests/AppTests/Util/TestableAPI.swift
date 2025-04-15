//
//  TestableAPI.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/22.
//

import Foundation
import Papyrus
import Vapor

@testable import App

protocol TestableAPI {
    init(provider: Provider)
}

func test<T: TestableAPI>(api: T.Type = T.self, _ block: (Application, T) async throws -> Void)
    async throws
{
    let app = try await Application.make(.testing)

    let api = T(provider: .vaporTestingProvider(app: app))
    do {
        try await configure(app)
        try await app.autoMigrate()
        try await block(app, api)
    }
    catch {
        try await app.autoRevert()
        try await app.asyncShutdown()
        throw error
    }
    try await app.autoRevert()
    try await app.asyncShutdown()
}
