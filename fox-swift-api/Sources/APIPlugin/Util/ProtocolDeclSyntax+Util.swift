//
//  ProtocolDeclSyntax+Util.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation
import SwiftSyntax

extension ProtocolDeclSyntax {
    var access: String {
        modifiers.first.map { $0.trimmedDescription + " " } ?? ""
    }

    var functions: any Sequence<FunctionDeclSyntax> {
        memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
