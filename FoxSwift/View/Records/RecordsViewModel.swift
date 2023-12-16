//
//  RecordsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import Foundation

final class RecordsViewModel {
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

    func deleteRecord(for index: Int) {
        FSUser.currentUser?.deleteRecord(meetingCode: meetingCodes.value[index].value)
        meetingCodes.value.remove(at: index)
        FSUserProvider.shared.updateCurrentUser()
    }

    func renameRecord(for index: Int, to newName: String) {}

    func moveRecord(from oldIndex: Int, to newIndex: Int) {
        let meetingCode = meetingCodes.value.remove(at: oldIndex)
        meetingCodes.value.insert(meetingCode, at: newIndex)
    }
}
