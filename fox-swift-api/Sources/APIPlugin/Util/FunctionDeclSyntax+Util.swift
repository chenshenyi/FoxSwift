//
//  File.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {
    var route: (httpMethod: String, path: String)? {
        for attribute in attributes {
            guard let attributeSyntax = attribute.as(AttributeSyntax.self),
                  let attributeFirstArgument = attributeSyntax.firstArgument(
                    StringLiteralExprSyntax.self
                  )?.representedLiteralValue
            else { continue }
            let attributeName = attributeSyntax.attributeName.trimmedDescription
            switch attributeName {
            case "GET", "DELETE", "PATCH", "POST", "PUT", "OPTIONS", "HEAD", "TRACE", "CONNECT":
                return (attributeName, attributeFirstArgument)
            default: continue
            }
        }
        return nil
    }

    var parameters: any Sequence<FunctionParameterSyntax> {
        signature.parameterClause.parameters
    }
}
