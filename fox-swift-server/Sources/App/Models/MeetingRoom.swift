//
//  MeetingRoom.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/27.
//

import Foundation
import FoxSwiftAPI
import Vapor

struct MeetingRoom: Identifiable {
    let id: UUID
    var users: [User.IDValue: WebSocket] = [:]

    init(id: UUID) {
        self.id = id
    }

    mutating func join(userId: User.IDValue, webSocket: WebSocket) {
        users[userId] = webSocket
    }
}
