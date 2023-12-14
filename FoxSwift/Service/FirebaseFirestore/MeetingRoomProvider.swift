//
//  FirebaseMeetingRoomProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

protocol MeetingRoomProviderDelegate: AnyObject {
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveInitial: [Participant])
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveNew: [Participant])
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveLeft: [Participant])
    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError: Error)
    func meetingRoom(
        _ provider: MeetingRoomProvider,
        startSharingScreen participant: Participant
    )
    func meetingRoom(
        _ provider: MeetingRoomProvider,
        stopSharingScreen participant: Participant
    )
}

/// Warning: This content is to substitute webSocket with Firestore
class MeetingRoomProvider {
    typealias CollectionManager = FSCollectionManager<MeetingRoom, MeetingRoom.CodingKeys>

    enum MeetingRoomError: Error {
        case cantSharingScreen
    }

    weak var delegate: MeetingRoomProviderDelegate?
    var meetingCode: String
    var meetingRoom: MeetingRoom?

    let collectionManager = CollectionManager(collection: .meetingRoom)

    var currentUser: Participant {
        Participant.currentUser
    }

    init(meetingCode: String) {
        self.meetingCode = meetingCode
    }

    class func create(completion: @escaping (Result<String, Error>) -> Void) {
        let meetingRoom = MeetingRoom()

        CollectionManager(collection: .meetingRoom)
            .createDocument(data: meetingRoom, completion: completion)
    }

    class func check(meetingCode: MeetingRoom.MeetingCode, completion: @escaping (Error?) -> Void) {
        CollectionManager(collection: .meetingRoom)
            .readDocument(documentID: meetingCode) { result in
                switch result {
                case .success: completion(nil)
                case let .failure(error): completion(error)
                }
            }
    }

    func connect() {
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
        collectionManager.removeObjects(
            objects: [currentUser],
            documentID: meetingCode,
            field: .participants
        )

        collectionManager.stopListenDocument(documentID: meetingCode)
    }

    func sharingScreen() throws {
        guard var meetingRoom,
              meetingRoom.screenSharer == nil
        else { throw MeetingRoomError.cantSharingScreen }

        self.meetingRoom?.screenSharer = currentUser
        meetingRoom.screenSharer = currentUser

        collectionManager.updateDocument(data: meetingRoom, documentID: meetingCode)
    }

    func stopSharingScreen() {
        guard meetingRoom?.screenSharer?.id == currentUser.id else { return }

        meetingRoom?.screenSharer = nil
        guard let meetingRoom else { return }

        collectionManager.updateDocument(data: meetingRoom, documentID: meetingCode)
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

            let newParticipants = Set(newMeetingRoom.participants)
                .subtracting(meetingRoom.participants)
                .subtracting([currentUser])

            delegate?.meetingRoom(self, didRecieveNew: Array(newParticipants))
            delegate?.meetingRoom(self, didRecieveLeft: Array(leftParticipants))
            
            let oldSharer = meetingRoom.screenSharer
            let newSharer = newMeetingRoom.screenSharer
            
            if oldSharer != newSharer {
                if let oldSharer {
                    delegate?.meetingRoom(self, stopSharingScreen: oldSharer)
                }

                if let newSharer {
                    delegate?.meetingRoom(self, startSharingScreen: newSharer)
                }
            }

            self.meetingRoom = newMeetingRoom
        case let .failure(error):
            delegate?.meetingRoom(self, didRecieveError: error)
        }
    }
}
