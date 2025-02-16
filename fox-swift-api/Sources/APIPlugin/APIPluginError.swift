//
//  APIPluginError.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/15.
//

import Foundation

public struct APIPluginError: Error, ExpressibleByStringLiteral, CustomDebugStringConvertible {
    public let debugDescription: String

    public init(stringLiteral value: StringLiteralType) {
        self.debugDescription = value
    }
}
