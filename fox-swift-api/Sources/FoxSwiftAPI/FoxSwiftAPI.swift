//
//  File.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Foundation
import APICore

public enum FoxSwiftAPI: APIProtocol {
    public enum Server: String, ServerProtocol {
        case local

        public var hostname: String {
            rawValue
        }

        public var port: UInt16? {
            switch self {
            case .local: 8080
            }
        }
    }
}
