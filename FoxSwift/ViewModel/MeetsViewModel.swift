//
//  MeetsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

import WebRTC

class MeetsViewModel {
    // MARK: - Network Provider
    private var meetingProvider: MeetingRoomProvider?
    private var participantDetailProvider: ParticipantDetailProvider?

    // MARK: - Binded Properties
    var activeMeeting: Box<MeetingCellViewModel?> = .init(nil)
    var meetingCode: Box<String> = .init("")

    // MARK: - Meeting
    func createNewCode() {
        MeetingRoomProvider.create { result in
            switch result {
            case let .success(meetingCode):
                self.meetingCode.value = meetingCode
            case let .failure(error):
                print(error)
            }
        }
    }

    func joinMeet(_ handler: (_ viewModel: MeetingViewModel) -> Void) {
        if meetingCode.value.isEmpty {
            return
        }
        let viewModel = MeetingViewModel(meetingCode: meetingCode.value)
        handler(viewModel)
    }
}
