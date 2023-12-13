//
//  RecordsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import Foundation

final class RecordsViewModel {
    var meetingCodes: Box<[Box<MeetingRoom.MeetingCode>]> = Box([])

    init() {
        FSUserProvider.shared.listenToCurrentUser { [weak self] user in
            guard let self else { return }

            meetingCodes.value = user.records.map { Box($0) }
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
