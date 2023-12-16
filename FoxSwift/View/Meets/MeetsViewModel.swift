//
//  MeetsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

class MeetsViewModel {
    // MARK: - Network Provider
    private var userProvider = FSUserProvider.shared

    // MARK: - Binded Properties
    var activeMeeting: Box<MeetingInfo?> = .init(nil)
    var meetingCode: Box<String> = .init("")
    var meets: Box<[Box<MeetingInfo>]> = .init([])

    func listenToUser() {
        userProvider.listenToCurrentUser { [weak self] user in
            guard let self else { return }
            FSUser.currentUser = user
            meets.value = user.recentMeets.map { Box($0) }
        }
    }

    // MARK: - Meeting
    func createNewCode(_ handler: @escaping (_ viewModel: MeetingPrepareViewModel) -> Void) {
        MeetingRoomProvider.create { result in
            switch result {
            case let .success(meetingCode):
                self.meetingCode.value = meetingCode
                handler(.init(meetingInfo: .init(meetingCode: meetingCode)))

            case let .failure(error):
                print(error)
            }
        }
    }

    func joinMeet(
        meetingInfo: MeetingInfo,
        handler: @escaping (_ viewModel: MeetingPrepareViewModel) -> Void
    ) {
        let viewModel = MeetingPrepareViewModel(meetingInfo: meetingInfo)
        handler(viewModel)
    }
}
