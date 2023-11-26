//
//  MessageProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import Foundation

class MessageProvider {
    var meetingCode: String
    let collectionManager: FSCollectionManager<
        FSMessage,
        FSMessage.CodingKeys
    >

    typealias MessageHandler = (FSMessage) -> Void

    init(meetingCode: String) {
        self.meetingCode = meetingCode
        collectionManager = .init(
            fatherDocument: [(collection: .meetingRoom, documentId: meetingCode)],
            collection: .messages
        )
    }

    func send(message: FSMessage) {
        collectionManager.createDocument(data: message)
    }

    func startListen(handler: @escaping MessageHandler) {
        collectionManager.listenCollection(listenToAddedOnly: true) { [weak self] result in
            self?.readResult(result: result, handler: handler)
        }
    }

    private func readResult(
        result: Result<[FSMessage], Error>,
        handler: @escaping MessageHandler
    ) {
        switch result {
        case let .success(messages):
            messages.forEach { message in
                handler(message)
            }
        case let .failure(error):
            debugPrint(error.localizedDescription.red)
        }
    }

    func stopListenMessage() {
        collectionManager.stopListenCollection()
    }
}
