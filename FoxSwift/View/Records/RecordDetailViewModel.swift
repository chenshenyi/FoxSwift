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

    func renameRecord(name: String) {}

    func editMessage(newText: String, messageId: FSMessage.ID) {}

    // MARK: Init
    init(meetingCode: MeetingRoom.MeetingCode) {
        self.meetingCode = meetingCode
        recordName = .init(meetingCode)
        messageProvider = MessageProvider(meetingCode: meetingCode)
        setupMessageProvider()
    }

    func setupMessageProvider() {
        messageProvider.startListen { [weak self] message in
            guard let self else { return }
            messages.value.append(message)
        }
    }

    // MARK: Deinit
    deinit {
        messageProvider.stopListenMessage()
    }
}
