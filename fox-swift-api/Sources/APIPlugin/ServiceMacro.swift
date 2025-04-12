//
//  ServiceMacro.swift
//  util
//
//  Created by chen shen yi on 2025/2/14.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct ServiceMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws(APIPluginError) -> [DeclSyntax] {
        guard let protocolDeclSyntax = declaration.as(ProtocolDeclSyntax.self) else {
            throw "@Service can only be applied to protocols."
        }

        let protocolName = protocolDeclSyntax.name.text
        let access = protocolDeclSyntax.access

        let routeCollectionName = "\(protocolName)RouteCollection"
        let serviceProtocolName = "\(protocolName)ServiceProtocol"

        return [
        """
        \(access)typealias \(serviceProtocolName) = ServiceProtocol&\(protocolName)
        """,
        """
        \(access)struct \(routeCollectionName)<Service: \(serviceProtocolName)>: ServiceRouteCollection {
            \(access)init() {}
        
            \(access)func boot(routes: any Vapor.RoutesBuilder) throws {
                \(try routes(protocolDeclSyntax: protocolDeclSyntax, in: context).joined())
            }
        }
        """
        ].map(DeclSyntax.init(stringLiteral:))
    }

    private static func routes(
        protocolDeclSyntax: ProtocolDeclSyntax,
        in context: some MacroExpansionContext
    ) throws(APIPluginError) -> [String] {
        protocolDeclSyntax.functions.compactMap { (functionDeclSyntax: FunctionDeclSyntax) -> String? in
            guard let (httpMethod, path) = functionDeclSyntax.route else { return nil }
            let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
            let pathComponentsAsFunctionParameter = pathComponents.map(\.quoted).joined(separator: ", ")
            let functionName = functionDeclSyntax.name.trimmedDescription
            let functionParameters = functionDeclSyntax.parameters
            
            return """
            routes.on(.init(rawValue: "\(httpMethod)"), \(pathComponentsAsFunctionParameter)) { request in
            \(initParameter(parameters: functionParameters, route: (httpMethod, pathComponents)).joined())
            return try await Service(request: request).\(functionName)(\(setParameter(parameters: functionParameters)))
            }
            """
        }
    }

    private typealias Route = (method: String, path: [String])
    private static func initParameter(
        parameters: any Sequence<FunctionParameterSyntax>,
        route: Route
    ) -> [String] {
        parameters.compactMap { (functionParameterSyntax: FunctionParameterSyntax) -> String? in
            let name = functionParameterSyntax.firstName.trimmedDescription
            let type = functionParameterSyntax.type.trimmedDescription
            let getValue = getValue(of: functionParameterSyntax, route: route)
            return "let \(name): \(type) = try request.\(getValue)\n"
        }
    }

    private static func getValue(
        of functionParameterSyntax: FunctionParameterSyntax,
        route: Route
    ) -> String {
        let name = functionParameterSyntax.secondName?.trimmedDescription
        ?? functionParameterSyntax.firstName.trimmedDescription

        if let identifierTypeSyntax = functionParameterSyntax.type.as(IdentifierTypeSyntax.self) {
            switch identifierTypeSyntax.name.trimmedDescription {
            case "Body":
                return "getBody()"
            case "Query":
                return "getQuery(at: \"\(name)\")"
            case "Path":
                return "getParameter(name: \"\(name)\")"
            default:
                break
            }
        }

        if route.path.contains(where: { isMatchedParameter(path: $0, name: name) }) {
            return "getParameter(name: \"\(name)\")"
        } else {
            return "getQuery(at: \"\(name)\")"
        }
    }

    private static func isMatchedParameter(path: String, name: String) -> Bool {
        path.hasPrefix(":") && path.trimmingPrefix(":") == name
    }

    private static func setParameter(
        parameters: any Sequence<FunctionParameterSyntax>
    ) -> String {
        parameters.map { functionParameterSyntax in
            let name = functionParameterSyntax.firstName.trimmedDescription
            return "\(name): \(name)"
        }
        .joined(separator: ", ")
    }
}
