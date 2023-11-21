//
//  FirebaseMeetingRoomProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

protocol MeetingRoomProviderDelegate: AnyObject {
    func meetingRoom(_ provider: MeetingRoomProvider, newMeetingCode: String, createdTime: Int)
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveInitial: [Participant])
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveNew: [Participant])
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveLeft: [Participant])
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError: Error)
}

/// Warning: This content is to substitute webSocket with Firestore
class MeetingRoomProvider {
    weak var delegate: MeetingRoomProviderDelegate?
    var meetingCode: String?
    var meetingRoom: MeetingRoom?

    private let collectionManager = FSCollectionManager<
        MeetingRoom,
        MeetingRoom.CodingKeys
    >(collection: .meetingRoom)

    var currentUser: Participant {
        Participant.currentUser
    }

    init(meetingCode: String? = nil) {
        self.meetingCode = meetingCode
    }

    func create() {
        let meetingRoom = MeetingRoom()
        self.meetingRoom = meetingRoom
        collectionManager.createDocument(data: meetingRoom) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(documentID):
                meetingCode = documentID
                let createdTime = meetingRoom.createdTime
                delegate?.meetingRoom(self, newMeetingCode: documentID, createdTime: createdTime)
            case let .failure(error):
                delegate?.meetingRoom(self, didRecieveError: error)
            }
        }
    }

    func connect() {
        guard let meetingCode else { return }

        collectionManager.unionObjects(
            objects: [currentUser],
            documentID: meetingCode,
            field: .participants
        )

        collectionManager.readDocument(
            documentID: meetingCode,
            completion: recieveRead
        )

        collectionManager.listenToDocument(
            documentID: meetingCode,
            completion: recieveListened
        )
    }

    func disconnect() {
        guard let meetingCode else { return }

        collectionManager.removeObjects(
            objects: [currentUser],
            documentID: meetingCode,
            field: .participants
        )

        collectionManager.stopListenDocument(documentID: meetingCode)
    }

    private func recieveRead(result: Result<MeetingRoom, Error>) {
        switch result {
        case let .success(newMeetingRoom):
            meetingRoom = newMeetingRoom

            let participants = Set(newMeetingRoom.participants)
                .subtracting([currentUser])

            delegate?.meetingRoom(self, didRecieveInitial: Array(participants))
        case let .failure(error):
            delegate?.meetingRoom(self, didRecieveError: error)
        }
    }

    private func recieveListened(result: Result<MeetingRoom, Error>) {
        switch result {
        case let .success(newMeetingRoom):
            guard let meetingRoom else { return }

            let leftParticipants = Set(meetingRoom.participants)
                .subtracting(newMeetingRoom.participants)
                .subtracting([currentUser])

            let newParticipants = Set(newMeetingRoom.participants)
                .subtracting(meetingRoom.participants)
                .subtracting([currentUser])

            delegate?.meetingRoom(self, didRecieveNew: Array(newParticipants))
            delegate?.meetingRoom(self, didRecieveLeft: Array(leftParticipants))

            self.meetingRoom = meetingRoom
        case let .failure(error):
            delegate?.meetingRoom(self, didRecieveError: error)
        }
    }
}
