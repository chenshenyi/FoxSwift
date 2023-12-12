//
//  MeetsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

class MeetsViewModel {
    // MARK: - Network Provider
    private var userProvider = FSUserProvider()

    // MARK: - Binded Properties
    var activeMeeting: Box<MeetingRoom.MeetingCode?> = .init(nil)
    var meetingCode: Box<String> = .init("")
    var meets: Box<[MeetingRoom.MeetingCode]> = .init([])

    func listenToUser() {
        userProvider.listenToCurrentUser { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(user):
                meets.value = user.recentMeets
            case let .failure(error):
                error.print()
            }
        }
    }

    // MARK: - Meeting
    func createNewCode(_ handler: @escaping (_ viewModel: MeetingPrepareViewModel) -> Void) {
        MeetingRoomProvider.create { result in
            switch result {
            case let .success(meetingCode):
                self.meetingCode.value = meetingCode
                handler(.init(meetingCode: meetingCode))
            case let .failure(error):
                print(error)
            }
        }
    }

    func joinMeet(
        meetingCode: MeetingRoom.MeetingCode,
        handler: @escaping (_ viewModel: MeetingPrepareViewModel) -> Void
    ) {
        let viewModel = MeetingPrepareViewModel(meetingCode: meetingCode)
        handler(viewModel)
    }
}
