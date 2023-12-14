//
//  Participant.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

struct Participant: Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var name: String = "小熊貓\(Int.random(in: 0 ... 9999))"
    var smallPicture: Data?

    static var currentUser: Participant {
        FSUser.currentUser?.participant ?? .init()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case smallPicture
    }
}
