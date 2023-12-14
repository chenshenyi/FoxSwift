//
//  SocketData.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/14.
//

import Foundation

enum SocketData: Codable {
    case RTCMessage(RTCMessage)
    case MeetingRoom(MeetingRoom)
}
