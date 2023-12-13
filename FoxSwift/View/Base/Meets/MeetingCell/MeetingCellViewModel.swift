//
//  MeetingCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import Foundation

class MeetingCellViewModel {
    let collectionManager: FSCollectionManager<
        MeetingRoom,
        MeetingRoom.CodingKeys
    > = .init(collection: .meetingRoom)

    var meetingCode: Box<String> = .init("")
    var createdTime: Box<Int?> = .init(nil)
    var meetingName: Box<String?> = .init(nil)

    var isSaved = Box(false)

    func setMeetingCode(meetingCode: MeetingRoom.MeetingCode) {
        self.meetingCode.value = meetingCode
        collectionManager.readDocument(documentID: meetingCode) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(meetingRoom):
                createdTime.value = meetingRoom.createdTime
            case let .failure(error):
                error.print()
            }
        }

        FSUserProvider.shared.listenToCurrentUser { [weak self] user in
            self?.isSaved.value = user.records.contains(where: { $0 == meetingCode })
        }
    }

    func save() {
        isSaved.value = true
        FSUser.currentUser?.addRecord(meetingCode: meetingCode.value)
        FSUserProvider.shared.updateCurrentUser()
    }

    func unsave() {
        isSaved.value = false
        FSUser.currentUser?.deleteRecord(meetingCode: meetingCode.value)
        FSUserProvider.shared.updateCurrentUser()
    }
}
