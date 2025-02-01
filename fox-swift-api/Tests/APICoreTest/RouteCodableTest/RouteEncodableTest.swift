//
//  RouteEncodableTest.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/1/24.
//

import Testing
import Dispatch
@testable import APICore

@Suite("Route Encodable Tests")
struct RouteEncodableTests {
    @Test(.serialized, arguments: [
        (TestRoute.home, "/home"),
        (.id(), "/id/3"),
        (.float(0.4), "/float/0.4"),
        (.bool(true), "/bool/true"),
        (.nested(nil), "/nested"),
        (.nested(.foo), "/nested/foo"),
        (.parameterName(name: "Chris"), "/parameterName/name/Chris"),
        (.twoPara(id: 3, userId: "abb"), "/twoPara/id/3/userId/abb"),
        (.array([2, 4, 4]), "/array/2/4/4"),
        (nil, "/"),
    ])
    func testBasicRouteEncoding(encodingValue: TestRoute?, expectedPathString: String) async throws {
        let pathString = try RouteEncoder().encode(with: encodingValue)
        #expect(pathString == expectedPathString)
    }
    
    @Test(.serialized, arguments: ([
        (1, "/1"),
        ("hello", "/hello"),
        (["a", "b"], "/a/b")
    ] as! [(any Encodable&Sendable, String)]))
    func testAnyCodable(encodingValue: any Encodable, expectedPathString: String) async throws {
        let pathString = try RouteEncoder().encode(with: encodingValue)
        #expect(pathString == expectedPathString)
    }
    
    @Test(arguments: [
        (StructureRoute(name: "hi", id: 4), "/name/hi/id/4")
    ])
    func testStructure(encodingValue: StructureRoute, expectedPathString: String) async throws {
        let pathString = try RouteEncoder().encode(with: encodingValue)
        #expect(pathString == expectedPathString)
    }

    enum CodingKeys: CodingKey {}
    @Test
    func testFatal() async throws {
        await #expect(throws: Fatal.methodNotImplement) {
            try await Fatal.test {
                var container = RouteKeyedEncodingContainer<CodingKeys>(components: Box(wrappedValue: [""]))
                _ = container.superEncoder()
            }
        }
    }
}
