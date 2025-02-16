//
//  UtilTests.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import Testing
import SwiftSyntax
@testable import APIPlugin

@Suite
struct UtilTests {
    @Suite
    struct FunctionDeclTests {
        @Test func route() async throws {
            let declString = """
            @GET("Path")
            func test()
            """
            let functionDecl = DeclSyntax(stringLiteral: declString).as(FunctionDeclSyntax.self)!

            #expect(("GET", "Path") == functionDecl.route!)
        }

        @Test func parameters() async throws {
            let declString = """
            func test(argumentLabel parameterName1: String, _ parameterName2: String, parameterName3: String)
            """
            let functionDecl = DeclSyntax(stringLiteral: declString).as(FunctionDeclSyntax.self)!

            let firstNames = [
                "argumentLabel",
                "_",
                "parameterName3"
            ]
            for value in zip(Array(functionDecl.parameters.map(\.firstName.trimmedDescription)), firstNames) {
                #expect(value.0 == value.1)
            }

            let secondNames = [
                "parameterName1",
                "parameterName2",
                nil
            ]
            for value in zip(Array(functionDecl.parameters.map(\.secondName?.trimmedDescription)), secondNames) {
                #expect(value.0 == value.1)
            }
        }
    }
}
