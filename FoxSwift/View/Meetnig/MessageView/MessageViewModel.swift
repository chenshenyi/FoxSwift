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
    private let fileManager = StorageManager.fileManager
    private let imageManager = StorageManager.imageManager

    var meetingCode: MeetingRoom.MeetingCode

    var messages: Box<[FSMessage]> = .init([], semaphore: 1)
    var speechMessages: Box<[FSMessage]> = .init([], semaphore: 1)

    // MARK: Init
    init(meetingCode: MeetingRoom.MeetingCode) {
        self.meetingCode = meetingCode
        messageProvider = MessageProvider(meetingCode: meetingCode)
        setupMessageProvider()
    }

    func setupMessageProvider() {
        messageProvider.startListen { [weak self] message in
            guard let self else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                switch message.type {
                case .speechText:
                    speechMessages.value.append(message)

                default:
                    messages.value.append(message)
                }
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
        imageManager.upload(
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
        fileManager.upload(
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

    enum MessageError: Error {
        case fileTooLarge
        case invalidFile
        case uploadError
    }

    func sendFile(localUrl: URL, handler: @escaping (MessageError?) -> Void) {
        guard localUrl.startAccessingSecurityScopedResource() else { return }

        do {
            let fileName = localUrl.lastPathComponent
            let resourceValue = try localUrl.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = resourceValue.fileSize ?? .max
            if fileSize > 5_000_000 {
                throw MessageError.fileTooLarge
            }

            guard let data = try? Data(contentsOf: localUrl) else {
                handler(.invalidFile)
                return
            }

            fileManager.upload(
                data: data,
                name: fileName
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(url):
                    let file = FSFile(
                        name: fileName,
                        size: fileSize,
                        urlString: url.absoluteString
                    )

                    guard let fileData = try? JSONEncoder().encode(file) else {
                        handler(.invalidFile)
                        return
                    }

                    let message = FSMessage(
                        data: fileData,
                        author: .currentUser,
                        type: .fileUrl
                    )

                    messageProvider.send(message: message)
                    handler(nil)

                case let .failure(error):
                    print(error.localizedDescription.red)
                    handler(.uploadError)
                }
            }
        } catch let error as MessageError {
            handler(error)
        } catch {
            handler(.invalidFile)
        }
    }
}
