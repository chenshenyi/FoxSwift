//
//  MessageViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import Foundation
import UIKit

class RecordDetailViewModel: RecordDetailViewModelProtocol {
    // MARK: Providers
    private let messageProvider: MessageProvider
    private let fileManager = StorageManager.fileManager
    private let imageManager = StorageManager.imageManager

    var meetingCode: MeetingRoom.MeetingCode

    var messages: Box<[FSMessage]> = .init([])

    var recordName: Box<String>

    func editMessage(newText: String, messageId: FSMessage.ID) {}

    // MARK: Init
    init(meetingCode: MeetingRoom.MeetingCode, name: String?) {
        self.meetingCode = meetingCode

        recordName = .init(name ?? meetingCode)
        messageProvider = MessageProvider(meetingCode: meetingCode)
        setupMessageProvider()
    }

    func setupMessageProvider() {
        messageProvider.startListen { [weak self] message in
            guard let self else { return }
            messages.value.append(message)
        }
    }

    lazy var meetingRoomProvider = MeetingRoomProvider(meetingCode: meetingCode)

    func renameRecord(name: String) {
        if name.isEmpty { return }
        recordName.value = name
        meetingRoomProvider.rename(name: name)
        FSUser.currentUser?.meetingHistory.first { meetingInfo in
            meetingInfo.meetingCode == meetingCode
        }?.meetingName = name
        FSUser.currentUser?.recentMeets.first {
            $0.meetingCode == meetingCode
        }?.meetingName = name
        FSUser.currentUser?.records.first {
            $0.meetingCode == meetingCode
        }?.meetingName = name
        FSUserProvider.shared.updateCurrentUser()
    }

    // MARK: Deinit
    deinit {
        messageProvider.stopListenMessage()
    }
}
