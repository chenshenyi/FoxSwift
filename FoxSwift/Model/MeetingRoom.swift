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
    var meetingName: String?
    var participants: [Participant] = []
    var screenSharer: Participant?

    enum CodingKeys: CodingKey {
        case createdTime
        case participants
        case screenSharer
        case meetingName
    }

    init() {
        createdTime = Int(Date().timeIntervalSinceReferenceDate)
    }

    func meetingInfo(meetingCode: MeetingCode) -> MeetingInfo {
        .init(meetingCode: meetingCode, createdTime: createdTime, meetingName: meetingName)
    }
}

class MeetingInfo: Codable {
    typealias MeetingCode = String

    let meetingCode: MeetingRoom.MeetingCode
    let createdTime: Int
    var meetingName: String?

    init(meetingCode: MeetingRoom.MeetingCode, createdTime: Int, meetingName: String? = nil) {
        self.meetingCode = meetingCode
        self.createdTime = createdTime
        self.meetingName = meetingName
    }

    init(meetingCode: MeetingRoom.MeetingCode) {
        self.meetingCode = meetingCode
        createdTime = Int(Date().timeIntervalSinceReferenceDate)
        meetingName = meetingCode
    }
}
