//
//  FSFile.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/18.
//

import Foundation

struct FSFile: Codable {
    var name: String
    var size: Int
    var urlString: String

    enum CodingKeys: CodingKey {
        case name
        case size
        case urlString
    }
}
