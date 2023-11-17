//
//  FirebaseMeetingRoomProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

struct MeetingRoom: Codable {
    let createdTime: Int
    var participants: [Participant] = []

    init() {
        createdTime = Int(Date().timeIntervalSinceReferenceDate)
    }

    enum Field: String, FSField {
        case createdTime
        case participants
    }
}

protocol MeetingRoomProviderDelegate: AnyObject {
    func meetingRoom(_ provider: MeetingRoomProvider, newMeetingCode: String)
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveUpdate: MeetingRoom)
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError: Error)
}

/// Warning: This content is to substitute webSocket with Firestore
class MeetingRoomProvider {
    weak var delegate: MeetingRoomProviderDelegate?
    var meetingCode: String?
    var meetingRoom: MeetingRoom?

    private let collectionManager = FSCollectionManager(collection: .meetingRoom)

    var currentUser: Participant {
        Participant.currentUser
    }

    init(meetingCode: String? = nil) {
        self.meetingCode = meetingCode
    }

    func create() {
        meetingRoom = MeetingRoom()
        collectionManager.createDocument(data: meetingRoom) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(documentId):
                meetingCode = documentId
                delegate?.meetingRoom(self, newMeetingCode: documentId)
            case let .failure(error):
                delegate?.meetingRoom(self, didRecieveError: error)
            }
        }
    }

    func connect() {
        guard let meetingCode else { return }

        collectionManager.unionDatas(
            datas: [currentUser],
            documentID: meetingCode,
            field: MeetingRoom.Field.participants
        )

        collectionManager.listenToDocument(
            asType: MeetingRoom.self,
            documentId: meetingCode,
            completion: recieveResult
        )
    }

    func disconnect() {
        guard let meetingCode else { return }

        collectionManager.removeDatas(
            datas: [currentUser],
            documentID: meetingCode,
            field: MeetingRoom.Field.participants
        )

        collectionManager.stopListenDocument(documentId: meetingCode)
    }

    private func updateMeetingRoom(meetingRoom: MeetingRoom) {
        guard let meetingCode else { return }

        collectionManager.updateDocument(
            data: meetingRoom,
            documentID: meetingCode,
            completion: recieveResult
        )
    }

    private func recieveResult(result: Result<MeetingRoom, Error>) {
        switch result {
        case let .success(meetingRoom):
            delegate?.meetingRoom(self, didRecieveUpdate: meetingRoom)
        case let .failure(error):
            delegate?.meetingRoom(self, didRecieveError: error)
        }
    }
}
