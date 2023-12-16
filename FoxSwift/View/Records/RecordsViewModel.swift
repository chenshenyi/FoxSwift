//
//  RecordsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import Foundation

final class RecordsViewModel {
    var meetingInfos: Box<[Box<MeetingInfo>]> = Box([])

    func loadData(completion: @escaping () -> Void) {
        Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            guard let user = FSUser.currentUser else { return }
            meetingInfos.value = user.records.map { Box($0) }
            timer.invalidate()
            completion()
        }
    }

    func deleteRecord(for index: Int) {
        FSUser.currentUser?.deleteRecord(meetingInfo: meetingInfos.value[index].value)
        meetingInfos.value.remove(at: index)
        FSUserProvider.shared.updateCurrentUser()
    }

    func renameRecord(for index: Int, to newName: String) {}

    func moveRecord(from oldIndex: Int, to newIndex: Int) {
        let meetingCode = meetingInfos.value.remove(at: oldIndex)
        meetingInfos.value.insert(meetingCode, at: newIndex)
    }
}
