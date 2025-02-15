//
//  File.swift
//  fox-swift-api
//
//  Created by chen shen yi on 2025/2/16.
//

import Foundation

extension Array where Element == String {
    var asLines: String {
        joined(separator: "\n")
    }
}

extension String {
    var quoted: String {
        "\"\(self)\""
    }
}
