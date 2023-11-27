//
//  MeetingCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import Foundation

class MeetingCellViewModel {
    var meetingCode: Box<String>
    var createdTime: Box<Int>
    var meetingName: Box<String>

    init(meetingCode: String, meetingRoom: MeetingRoom, meetingName: String? = nil) {
        self.meetingCode = .init(meetingCode)
        createdTime = .init(meetingRoom.createdTime)
        self.meetingName = .init(meetingName ?? meetingCode)
    }
}
