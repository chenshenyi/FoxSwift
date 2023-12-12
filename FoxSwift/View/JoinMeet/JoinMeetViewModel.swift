//
//  JoinMeetViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/12.
//

import Foundation

class JoinMeetViewModel {
    enum JoinMeetError: Error {
        case meetingNotExist
    }

    var userProvider = FSUserProvider()

    func joinMeet(
        meetingCode: MeetingRoom.MeetingCode,
        _ handler: @escaping (_ result: Result<MeetingPrepareViewModel, JoinMeetError>) -> Void
    ) {
        if meetingCode.isEmpty {
            return
        }

        MeetingRoomProvider.check(meetingCode: meetingCode) { [weak self] error in
            guard let self, error == nil else {
                DispatchQueue.main.async {
                    handler(.failure(.meetingNotExist))
                }
                return
            }

            FSUser.currentUser?.addHistory(meetingCode: meetingCode)
            userProvider.updateCurrentUser()

            let viewModel = MeetingPrepareViewModel(meetingCode: meetingCode)
            DispatchQueue.main.async {
                handler(.success(viewModel))
            }
        }
    }
}
