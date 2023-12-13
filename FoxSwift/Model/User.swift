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
    var picture: String = DefaultImage.profileImage.rawValue
    var bannerPicture: String = DefaultImage.banner.rawValue
    var description: String = "Describe yourself."

    private(set) var meetingHistory: [MeetingRoom.MeetingCode] = []
    private(set) var recentMeets: [MeetingRoom.MeetingCode] = []
    private(set) var records: [MeetingRoom.MeetingCode] = []

    // - MARK: CodingKey
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case password
        case picture
        case bannerPicture
        case meetingHistory
        case recentMeets
        case records
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

    mutating func addRecent(meetingCode: MeetingRoom.MeetingCode) {
        deleteRecent(meetingCode: meetingCode)
        recentMeets.insert(meetingCode, at: 0)
    }

    mutating func deleteRecent(meetingCode: MeetingRoom.MeetingCode) {
        recentMeets.removeAll { storedMeetingCode in
            storedMeetingCode == meetingCode
        }
    }
    
    mutating func addRecord(meetingCode: MeetingRoom.MeetingCode) {
        deleteRecord(meetingCode: meetingCode)
        records.insert(meetingCode, at: 0)
    }
    
    mutating func deleteRecord(meetingCode: MeetingRoom.MeetingCode) {
        records.removeAll { storedMeetingCode in
            storedMeetingCode == meetingCode
        }
    }
}

extension FSUser {
    var participant: Participant {
        Participant(id: id, name: name)
    }
}
