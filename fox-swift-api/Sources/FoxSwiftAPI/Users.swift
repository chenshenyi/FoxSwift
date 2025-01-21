//
//  Users.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Foundation
import APICore

extension FoxSwiftAPI {
    public struct User: Codable, Sendable {
        let id: String
        let name: String
        let createdDate: Date
        let updatedDate: Date
    }
}

extension FoxSwiftAPI {
    public enum GetUser: EndPointProtocol {
        public typealias ResponseBody = User

        public static func path(_ id: Int) -> String {
            "users/\(id)"
        }
    }
}

extension FoxSwiftAPI {
    public enum GetUsers: EndPointProtocol {
        public struct Query: Codable, Sendable {
            let createdDateBefore: Date?
            let createdDateAfter: Date?
        }

        public typealias ResponseBody = [User]

        public static func path(_ parameter: Void) -> String {
            "users"
        }
    }
}
