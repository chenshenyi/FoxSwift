//
//  MessageViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import Foundation
import UIKit

class MessageViewModel {
    // MARK: Providers
    private let messageProvider: MessageProvider
    private let fileProvider = StorageManager(folder: .file)
    private let imageProvider = StorageManager(folder: .image)

    var meetingCode: MeetingRoom.MeetingCode

    var messages: Box<[FSMessage]> = .init([])

    // MARK: Init
    init(meetingCode: MeetingRoom.MeetingCode) {
        self.meetingCode = meetingCode
        messageProvider = MessageProvider(meetingCode: meetingCode)
    }

    func setupMessageProvider() {
        messageProvider.startListen { [weak self] message in
            guard let self else { return }
            switch message.type {
            case .imageUrl:
                guard let urlString = String(data: message.data, encoding: .utf8),
                    let url = URL(string: urlString) else { return }
                imageProvider.download(url: url) { result in
                    switch result {
                    case let .success(data):
                        guard let image = UIImage(data: data) else { return }
                        var message = message
                        message.data = data
                        message.type = .image
                    case let .failure(error):
                        print(error.localizedDescription.red)
                    }
                }
            default:
                messages.value.append(message)
            }
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

    func sendVoiceMessage(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        let message = FSMessage(data: data, author: .currentUser, type: .speechText)

        messageProvider.send(message: message)
    }

    func sendImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        imageProvider.upload(
            data: data,
            name: UUID().uuidString
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(url):
                guard let message = FSMessage(string: url.absoluteString, type: .imageUrl)
                else { return }
                messageProvider.send(message: message)
            case let .failure(error):
                print(error.localizedDescription.red)
            }
        }
    }

    func sendFile(data: Data) {
        fileProvider.upload(
            data: data,
            name: UUID().uuidString
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(url):
                guard let message = FSMessage(string: url.absoluteString, type: .fileUrl)
                else { return }
                messageProvider.send(message: message)
            case let .failure(error):
                print(error.localizedDescription.red)
            }
        }
    }
}
