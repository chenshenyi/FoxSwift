//
//  VaporPapyrusTestingTests.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/18.
//

import Foundation
import Papyrus
import Testing
import VaporTesting

@testable import APICore

@API
@Service
protocol Coolest {
    @GET("/getHello")
    func getHello() async throws -> Res<String>

    @POST("/echo")
    func echo(word: Body<String>) async throws -> Res<String>

    @PUT("/echo/:path")
    func echo(path: Path<Int>) async throws -> Res<Int>

    @GET("/queryItems")
    func queryItems(limit: Int) async throws -> Res<Int>
}

struct CoolestService: CoolestServiceProtocol {
    var request: Vapor.Request

    func getHello() async throws -> Res<String> {
        .init("Hello World")
    }

    func echo(word: String) async throws -> Res<String> {
        .init(word + "!!")
    }

    func echo(path: Int) async throws -> Res<Int> {
        .init(path)
    }

    func queryItems(limit: Int) async throws -> Res<Int> {
        .init(limit + 1)
    }
}

struct Res<T: Codable & Equatable & Content>: Content, Codable, Equatable, AsyncResponseEncodable {
    var payload: T
    init(_ payload: T) { self.payload = payload }
    static func == (lhs: Self, rhs: T) -> Bool {
        return lhs.payload == rhs
    }
}

@Suite(.serialized)
struct VaporPapyrusTestingTests {
    struct WithAPITests {
        func withApi(_ block: (CoolestAPI) async throws -> Void) async throws {
            let app = try await Application.make(.testing)

            try app.register(collection: CoolestRouteCollection<CoolestService>())
            let api = CoolestAPI(provider: .vaporTestingProvider(app: app))
            do {
                try await block(api)
            } catch {
                try await app.asyncShutdown()
                throw error
            }
            try await app.asyncShutdown()
        }

        @Test func testRethrow() async throws {
            let err = NSError(domain: "", code: -1)
            await #expect(throws: err) {
                try await withApi { api in
                    throw err
                }
            }
        }

        @Test func getHello() async throws {
            try await withApi { api in
                let res = try await api.getHello()
                #expect(res == "Hello World")
            }
        }

        @Test func echoWord() async throws {
            try await withApi { api in
                let res = try await api.echo(word: "Hello")
                #expect(res == "Hello!!")
            }
        }

        @Test func echoPath() async throws {
            try await withApi { api in
                let res = try await api.echo(path: 5)
                #expect(res == 5)
            }
        }

        @Test func queryItems() async throws {
            try await withApi { api in
                let res = try await api.queryItems(limit: 10)
                #expect(res == 11)
            }
        }
    }

    @Test func completionNotImplemented() async throws {
        let app = try await Application.make(.testing)
        let provider = Provider.vaporTestingProvider(app: app)
        let requestBuilder = RequestBuilder(baseURL: "", method: "", path: "")
        provider.request(requestBuilder) { res in
            #expect(res.error as? TestingRequestError == .functionNotImplemented)
        }
        try await app.asyncShutdown()
    }

    @Test func appEarlyTeriminated() async throws {
        await #expect(throws: TestingRequestError.appNotExist) {
            var app: Application? = try await Application.make(.testing, .singleton)
            try await app?.asyncShutdown()

            let provider = app.map { Provider.vaporTestingProvider(app: $0) }
            let api = provider.map { CoolestAPI(provider: $0) }
            app = nil
            _ = try await api?.getHello()

        }
    }
}
