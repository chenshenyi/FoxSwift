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
    var meetingName: Box<String> = .init("")
    var meetingInfo: MeetingInfo?

    var isSaved = Box(false)

    func setMeetingInfo(meetingInfo: MeetingInfo) {
        self.meetingInfo = meetingInfo
        meetingCode.value = meetingInfo.meetingCode
        createdTime.value = meetingInfo.createdTime
        meetingName.value = meetingInfo.meetingName ?? meetingCode.value
        FSUserProvider.shared.listenToCurrentUser { [weak self] user in
            self?.isSaved.value = user.records.contains { [weak self] saved in
                saved.meetingCode == self?.meetingCode.value
            }
        }
    }

    func save() {
        isSaved.value = true
        guard let meetingInfo else { return }
        FSUser.currentUser?.addRecord(meetingInfo: meetingInfo)
        FSUserProvider.shared.updateCurrentUser()
    }

    func unsave() {
        isSaved.value = false
        guard let meetingInfo else { return }
        FSUser.currentUser?.deleteRecord(meetingInfo: meetingInfo)
        FSUserProvider.shared.updateCurrentUser()
    }
}
