//
//  MacroTests.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import MacroTesting
import Testing

@testable import APIPlugin

@Suite("Macro Tests")
struct MacroTests {
    func assertMacroWithAllMacro(
        of originalSource: () throws -> String,
        diagnostics diagnosedSource: (() -> String)? = nil,
        fixes fixedSource: (() -> String)? = nil,
        expansion expandedSource: (() -> String)? = nil,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        function: StaticString = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        assertMacro(
            ["Service": ServiceMacro.self],
            of: originalSource,
            diagnostics: diagnosedSource,
            fixes: fixedSource,
            expansion: expandedSource,
            fileID: fileID,
            file: filePath,
            function: function,
            line: line,
            column: column
        )
    }

    /// Just increase coverage
    @Test func testMacros() async throws {
        _ = MyPlugin().providingMacros
    }

    @Test func dianoseNoProtocol() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            struct Test {}
            """
        } diagnostics: {
            """
            @Service
            ┬───────
            ╰─ 🛑 @Service can only be applied to protocols.
            struct Test {}
            """
        }
    }

    @Test func emptyProtocolTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            protocol Test {}
            """
        } expansion: {
            """
            protocol Test {}

            typealias TestServiceProtocol = ServiceProtocol & Test

            struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                init() {
                }

                func boot(routes: any Vapor.RoutesBuilder) throws {

                }
            }
            """
        }
    }

    @Test func noArgumentsTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @GET("/test")
                func test()
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @GET("/test")
                func test()
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "GET"), "test") { request in

                        return try await Service(request: request).test()
                    }
                }
            }
            """#
        }
    }

    @Test func notRoutableAttributesTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @NONRELATED
                @GET
                func test()
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @NONRELATED
                @GET
                func test()
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {

                }
            }
            """#
        }
    }

    @Test func longPathTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @GET("/test/:id/name")
                func test()
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @GET("/test/:id/name")
                func test()
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "GET"), "test", ":id", "name") { request in

                        return try await Service(request: request).test()
                    }
                }
            }
            """#
        }
    }

    @Test func queryArgumentTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @GET("/test/:id/name")
                func test(name: String)
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @GET("/test/:id/name")
                func test(name: String)
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "GET"), "test", ":id", "name") { request in
                        let name: String = try request.getQuery(at: "name")

                        return try await Service(request: request).test(name: name)
                    }
                }
            }
            """#
        }
    }

    @Test func pathParameterTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @GET("/test/:id/name")
                func test(id: Int)
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @GET("/test/:id/name")
                func test(id: Int)
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "GET"), "test", ":id", "name") { request in
                        let id: Int = try request.getParameter(name: "id")

                        return try await Service(request: request).test(id: id)
                    }
                }
            }
            """#
        }
    }

    @Test func requestBodyTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @POST("/test/:id/name")
                func test(body: Body<MyCodable>)
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @POST("/test/:id/name")
                func test(body: Body<MyCodable>)
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "POST"), "test", ":id", "name") { request in
                        let body: Body<MyCodable> = try request.getBody()

                        return try await Service(request: request).test(body: body)
                    }
                }
            }
            """#
        }
    }

    @Test func responseValueTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @POST("/test/:id/name")
                func test() -> MyCodable
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @POST("/test/:id/name")
                func test() -> MyCodable
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "POST"), "test", ":id", "name") { request in

                        return try await Service(request: request).test()
                    }
                }
            }
            """#
        }
    }

    @Test func complicatedPathTest() async throws {
        assertMacroWithAllMacro {
            """
            @Service
            public protocol Test {
                @POST("/test/:id/name?limit=3#times")
                func test(body: Body<MyCodable>, id: Int, name: String, something: Path<MyParameter>, generic: MyGeneric<T>, nothing: Query<Bool>) -> MyCodable
            }
            """
        } expansion: {
            #"""
            public protocol Test {
                @POST("/test/:id/name?limit=3#times")
                func test(body: Body<MyCodable>, id: Int, name: String, something: Path<MyParameter>, generic: MyGeneric<T>, nothing: Query<Bool>) -> MyCodable
            }

            public typealias TestServiceProtocol = ServiceProtocol & Test

            public struct TestRouteCollection<Service: TestServiceProtocol>: ServiceRouteCollection {
                public init() {
                }

                public func boot(routes: any Vapor.RoutesBuilder) throws {
                    routes.on(.init(rawValue: "POST"), "test", ":id", "name") { request in
                        let body: Body<MyCodable> = try request.getBody()
                        let id: Int = try request.getParameter(name: "id")
                        let name: String = try request.getQuery(at: "name")
                        let something: Path<MyParameter> = try request.getParameter(name: "something")
                        let generic: MyGeneric<T> = try request.getQuery(at: "generic")
                        let nothing: Query<Bool> = try request.getQuery(at: "nothing")

                        return try await Service(request: request).test(body: body, id: id, name: name, something: something, generic: generic, nothing: nothing)
                    }
                }
            }
            """#
        }
    }
}
