//
//  URLComponentsExtension.swift
//  FoxSwiftAPI
//
//  Created by chen shen yi on 2025/1/18.
//

import Foundation

extension URLComponents {
    var paths: [String] {
        get {
            path.components(separatedBy: "/").filter { !$0.isEmpty }
        }
        set {
            path = newValue.map {
                $0.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            }.joined(separator: "/")
        }
    }
}
