//
//  RequestExtensionTests.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import Foundation
import Testing
import VaporTesting

@testable import APICore

extension RouteError: Equatable {
    public static func == (lhs: APICore.RouteError, rhs: APICore.RouteError) -> Bool {
        lhs.name == rhs.name
    }
}

@Suite
struct RequestExtensionTests {
    private func testInternalError<T: AsyncResponseEncodable>(
        path: String = "",
        pathComponent: PathComponent...,
        test: @Sendable @escaping (Request) async throws -> T
    ) async throws {
        let app = try await Application.make(.testing)
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            Task {
                app.get(pathComponent) { request in
                    do {
                        let res = try await test(request)
                        continuation.resume()
                        return res
                    } catch {
                        continuation.resume(throwing: error)
                        throw error
                    }
                }
                try await app.testing().test(.GET, path) { _ in }
                try await app.asyncShutdown()
            }
        }
    }

    @Test func noErrorTest() async throws {
        try await testInternalError(path: "/users/bob", pathComponent: "users", ":name") {
            request in
            let bob: String = try request.getParameter(name: "name")
            return bob
        }
    }

    @Test func getBodyErrorTest() async throws {
        await #expect(throws: RouteError.bodyDecodingError("")) {
            try await testInternalError { request in
                let body: String = try request.getBody()
                return body
            }
        }
    }

    @Test func getQueryErrorTest() async throws {
        await #expect(throws: RouteError.queryDecodingError(name: "", message: "")) {
            try await testInternalError { request in
                let query: String = try request.getQuery(at: "")
                return query
            }
        }
    }

    @Test func getParameterErrorTest() async throws {
        await #expect(throws: RouteError.missingPathParameter(name: "", type: Any.self)) {
            try await testInternalError { request in
                let parameter: String = try request.getParameter(name: "")
                return parameter
            }
        }
    }
}
