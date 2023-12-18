//
//  DrawingProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/19.
//

import Foundation
import PencilKit

class DrawingProvider {
    var meetingCode: MeetingRoom.MeetingCode
    let collectionManager: FSCollectionManager<
        PKStroke,
        PKStroke.CodingKeys
    >

    typealias StrokeHandler = (PKStroke) -> Void

    init(meetingCode: String) {
        self.meetingCode = meetingCode
        collectionManager = .init(
            fatherDocument: [(collection: .meetingRoom, documentId: meetingCode)],
            collection: .strokes
        )
    }

    func send(stroke: PKStroke) {
        collectionManager.createDocument(data: stroke)
    }

    func startListen(handler: @escaping StrokeHandler) {
        collectionManager.listenCollection(
            listenToAddedOnly: true
        ) { [weak self] result in
            self?.readResult(result: result, handler: handler)
        }
    }

    private func readResult(
        result: Result<[PKStroke], Error>,
        handler: @escaping StrokeHandler
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
