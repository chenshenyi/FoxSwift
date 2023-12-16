//
//  HistoryViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/16.
//

import UIKit

final class HistoryViewModel {
    var meetingCodes: Box<[Box<MeetingRoom.MeetingCode>]> = Box([])

    func loadData(completion: @escaping () -> Void) {
        FSUserProvider.shared.readCurrentUser { [weak self] user in
            guard let self else { return }
            if let user {
                meetingCodes.value = user.meetingHistory.map { Box($0) }
            }
            completion()
        }
    }

    func deleteHistory(for index: Int) {
        FSUser.currentUser?.deleteHistory(meetingCode: meetingCodes.value[index].value)
        meetingCodes.value.remove(at: index)
        FSUserProvider.shared.updateCurrentUser()
    }

    func renameHistory(for index: Int, to newName: String) {}

    func prepareViewModel(for indexPath: IndexPath) -> MeetingPrepareViewModel {
        let meetingCode = meetingCodes.value[indexPath.row].value
        return .init(meetingCode: meetingCode)
    }
}
