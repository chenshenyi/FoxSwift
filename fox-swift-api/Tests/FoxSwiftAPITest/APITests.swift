//
//  TestUsers.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import Testing
@testable import FoxSwiftAPI


@Suite
struct APITests {
    @Test func apiVersion() async throws {
        #expect(FS.apiVersion == 1)
        #expect(FS.basePath == "/api/v1")
    }

    @Test func userTests() async throws {
        _ = FS.User(account: "", name: "")
    }
}
