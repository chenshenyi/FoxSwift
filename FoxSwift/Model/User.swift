//
//  User.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

struct FSUser: Codable {
    typealias UserId = String

    static var currentUser: FSUser?

    // - MARK: Properties
    let id: UserId
    var name: String
    private(set) var meetingHistory: [MeetingRoom.MeetingCode] = []

    // - MARK: CodingKey
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case meetingHistory
    }

    // - MARK: Computed Properties
    var participant: Participant {
        Participant(id: id, name: name)
    }

    mutating func addHistory(meetingCode: MeetingRoom.MeetingCode) {
        deleteHistory(meetingCode: meetingCode)
        meetingHistory.insert(meetingCode, at: 0)
    }

    mutating func deleteHistory(meetingCode: MeetingRoom.MeetingCode) {
        meetingHistory.removeAll { storedMeetingCode in
            storedMeetingCode == meetingCode
        }
    }
}
