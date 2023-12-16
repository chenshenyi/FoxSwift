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

    var userProvider: FSUserProvider {
        .shared
    }

    func joinMeet(
        meetingCode: MeetingRoom.MeetingCode,
        _ handler: @escaping (_ result: Result<MeetingPrepareViewModel, JoinMeetError>) -> Void
    ) {
        if meetingCode.isEmpty {
            return
        }

        MeetingRoomProvider.check(meetingCode: meetingCode) { [weak self] meetingRoom in
            guard let self, let meetingRoom else {
                DispatchQueue.main.async {
                    handler(.failure(.meetingNotExist))
                }
                return
            }

            let meetingInfo = meetingRoom.meetingInfo(meetingCode: meetingCode)
            FSUser.currentUser?.addHistory(meetingInfo: meetingInfo)
            userProvider.updateCurrentUser()

            let viewModel = MeetingPrepareViewModel(meetingInfo: meetingInfo)
            DispatchQueue.main.async {
                handler(.success(viewModel))
            }
        }
    }
}
