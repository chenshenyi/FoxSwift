//
//  HistoryViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/16.
//

import UIKit

final class HistoryViewModel {
    var meetingInfos: Box<[Box<MeetingInfo>]> = Box([])

    func loadData(completion: @escaping () -> Void) {
        FSUserProvider.shared.readCurrentUser { [weak self] user in
            guard let self else { return }
            if let user {
                meetingInfos.value = user.meetingHistory.map { Box($0) }
            }
            completion()
        }
    }

    func deleteHistory(for index: Int) {
        FSUser.currentUser?.deleteHistory(meetingInfo: meetingInfos.value[index].value)
        meetingInfos.value.remove(at: index)
        FSUserProvider.shared.updateCurrentUser()
    }

    func renameHistory(for index: Int, to newName: String) {}

    func prepareViewModel(for indexPath: IndexPath) -> MeetingPrepareViewModel {
        let meetingInfo = meetingInfos.value[indexPath.row].value
        return .init(meetingInfo: meetingInfo)
    }
}
