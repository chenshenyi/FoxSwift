//
//  MeetingRoom.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import Foundation


struct MeetingRoom: Codable {
    typealias MeetingCode = String
    
    let createdTime: Int
    var participants: [Participant] = []

    enum CodingKeys: CodingKey {
        case createdTime
        case participants
    }

    init() {
        createdTime = Int(Date().timeIntervalSinceReferenceDate)
    }
}
