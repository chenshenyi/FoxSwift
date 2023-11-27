//
//  MessageViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import Foundation

class MessageViewModel {
    private let messageProvider: MessageProvider

    var meetingCode: MeetingRoom.MeetingCode

    var messages: Box<[FSMessage]> = .init([])

    // MARK: Init
    init(meetingCode: MeetingRoom.MeetingCode) {
        self.meetingCode = meetingCode
        messageProvider = MessageProvider(meetingCode: meetingCode)
        messageProvider.startListen { [weak self] message in
            self?.messages.value.append(message)
        }
    }

    // MARK: Deinit
    deinit {
        messageProvider.stopListenMessage()
    }

    // MARK: - Send Message
    func sendMessage(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        let message = FSMessage(data: data, author: .currentUser, type: .text)

        messageProvider.send(message: message)
    }
}
