//
//  Participant.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

struct Participant: Codable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var name: String = "小熊貓\(Int.random(in: (0...9999)))"
    static var currentUser: Participant = .init()
}
