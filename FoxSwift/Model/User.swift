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
    var smallPicture: Data? = DefaultImage.profileImage.imageData
    var bannerPicture: String = DefaultImage.banner.rawValue
    var description: String = "Describe yourself."

    private(set) var meetingHistory: [MeetingInfo] = []
    private(set) var recentMeets: [MeetingInfo] = []
    private(set) var records: [MeetingInfo] = []

    // - MARK: CodingKey
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case password
        case picture
        case smallPicture
        case bannerPicture
        case meetingHistory
        case recentMeets
        case records
    }

    mutating func addHistory(meetingInfo: MeetingInfo) {
        deleteHistory(meetingInfo: meetingInfo)
        meetingHistory.insert(meetingInfo, at: 0)
    }

    mutating func deleteHistory(meetingInfo: MeetingInfo) {
        meetingHistory.removeAll { storedInfo in
            storedInfo.meetingCode == meetingInfo.meetingCode
        }
    }

    mutating func addRecent(meetingInfo: MeetingInfo) {
        deleteRecent(meetingInfo: meetingInfo)
        recentMeets.insert(meetingInfo, at: 0)
        if recentMeets.count > 5 {
            recentMeets.removeLast(recentMeets.count - 5)
        }
    }

    mutating func deleteRecent(meetingInfo: MeetingInfo) {
        recentMeets.removeAll { storedMeetingInfo in
            storedMeetingInfo.meetingCode == meetingInfo.meetingCode
        }
    }

    mutating func addRecord(meetingInfo: MeetingInfo) {
        deleteRecord(meetingInfo: meetingInfo)
        records.insert(meetingInfo, at: 0)
    }

    mutating func deleteRecord(meetingInfo: MeetingInfo) {
        records.removeAll { storedInfo in
            storedInfo.meetingCode == meetingInfo.meetingCode
        }
    }
}

extension FSUser {
    var participant: Participant {
        Participant(id: id, name: name, smallPicture: smallPicture)
    }
}
