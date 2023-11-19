//
//  MeetingRoom.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import Foundation


struct MeetingRoom: Codable {
    let createdTime: Int
    var participants: [Participant] = []

    init() {
        createdTime = Int(Date().timeIntervalSinceReferenceDate)
    }

    enum Field: String, FSField {
        case createdTime
        case participants
    }
}
