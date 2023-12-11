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
    var email: String = ""
    var password: String = ""
    var picture: String = "Default"
    var bannerPicture: String = "Default"
    var description: String = "Describe yourself."

    private(set) var meetingHistory: [MeetingRoom.MeetingCode] = []

    // - MARK: CodingKey
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case password
        case picture
        case bannerPicture
        case meetingHistory
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

extension FSUser {
    var participant: Participant {
        Participant(id: id, name: name)
    }
}
