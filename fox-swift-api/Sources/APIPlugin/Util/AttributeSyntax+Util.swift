//
//  AttributeSyntax+Util.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import SwiftSyntax

extension AttributeSyntax {
    func firstArgument<T: ExprSyntaxProtocol>(_: T.Type = T.self) -> T? {
        switch arguments {
        case let .argumentList(labeledExprListSyntax):
            return labeledExprListSyntax.first?.expression.as(T.self)
        default:
            return nil
        }
    }
}
