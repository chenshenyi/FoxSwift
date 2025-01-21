//
//  File.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/20.
//

import Foundation
import APICore

extension FoxSwiftAPI {
    public enum CommonError: String, Error, Codable, Sendable {
        case invalidPath
        case invalidQuery
        case invalidBody
    }
}

extension EndPointProtocol {
    public typealias Error = FoxSwiftAPI.CommonError
}
