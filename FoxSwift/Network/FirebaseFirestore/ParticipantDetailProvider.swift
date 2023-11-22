//
//  ParticipantDetailProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

protocol ParticipantDetailProviderDelegate: AnyObject {
    func didGetOffer(_ provider: ParticipantDetailProvider, sdp: SessionDescription)
    func didGetAnswer(_ provider: ParticipantDetailProvider, sdp: SessionDescription)
    func didGetCandidate(_ provider: ParticipantDetailProvider, iceCandidate: IceCandidate)
    func didGetError(_ provider: ParticipantDetailProvider, error: Error)
}

class ParticipantDetailProvider {
    weak var delegate: ParticipantDetailProviderDelegate?

    typealias VoidManager = FSCollectionManager<
        VoidCodable,
        VoidCodable.CodingKeys
    >

    typealias SdpManager = FSCollectionManager<
        SessionDescription,
        SessionDescription.CodingKeys
    >

    typealias CandidateManager = FSCollectionManager<
        IceCandidateList,
        IceCandidateList.CodingKeys
    >

    private let currentUserSubCollections: [FSCollection: VoidManager]

    private let offerManager: SdpManager

    private let answerManager: SdpManager

    private let iceCandidatesManager: CandidateManager

    private var offerSubCollectionManagers: [String: SdpManager] = [:]

    private var answerSubCollectionManagers: [String: SdpManager] = [:]

    private var iceCandidatesSubCollectionManagers: [String: CandidateManager] = [:]

    private var oldCandidates: [String: [IceCandidate]] = [:]

    private var currentUserId: String {
        Participant.currentUser.id
    }

    init?(meetingRoomProvider: MeetingRoomProvider) {
        guard let meetingCode = meetingRoomProvider.meetingCode else { return nil }

        let collectionManager = meetingRoomProvider.collectionManager
        currentUserSubCollections = [FSCollection.offerSdp, .answerSdp, .iceCandidates]
            .reduce(into: [:]) { partialResult, collection in
                partialResult[collection] = collectionManager.subCollectionManager(
                    documentID: meetingCode,
                    subCollection: collection
                )
            }

        offerManager = currentUserSubCollections[.offerSdp]!.subCollectionManager(
            documentID: meetingCode,
            subCollection: .withParticipant
        )

        answerManager = currentUserSubCollections[.answerSdp]!.subCollectionManager(
            documentID: meetingCode,
            subCollection: .withParticipant
        )

        iceCandidatesManager = currentUserSubCollections[.iceCandidates]!.subCollectionManager(
            documentID: meetingCode,
            subCollection: .withParticipant
        )
    }

    func send(_ sdp: SessionDescription, to participantId: String) {
        let manager: SdpManager

        switch sdp.type {
        case .offer:
            manager = offerManager
        case .answer, .prAnswer:
            manager = answerManager
        case .rollback:
            fatalError("Can't send such sdp")
        }

        manager.createDocument(
            data: sdp,
            documentID: participantId
        )
    }

    func send(_ iceCandidate: IceCandidate, to participantId: String) {
        iceCandidatesManager.unionObjects(
            objects: [iceCandidate],
            documentID: participantId,
            field: .iceCandidates
        )
    }

    func startListenOffer(participantId: String) {
        guard let manager = currentUserSubCollections[.offerSdp] else { return }
        let offerSubManager: SdpManager = manager.subCollectionManager(
            documentID: participantId,
            subCollection: .withParticipant
        )

        offerSubCollectionManagers[participantId] = offerSubManager

        offerSubManager.listenToDocument(documentID: currentUserId, completion: handleSdp)
        offerSubManager.readDocument(documentID: currentUserId, completion: handleSdp)
    }

    func startListenAnswer(participantId: String) {
        guard let manager = currentUserSubCollections[.answerSdp] else { return }
        let answerManager: SdpManager = manager.subCollectionManager(
            documentID: participantId,
            subCollection: .withParticipant
        )

        answerSubCollectionManagers[participantId] = answerManager

        answerManager.listenToDocument(documentID: participantId, completion: handleSdp)
        answerManager.readDocument(documentID: participantId, completion: handleSdp)
    }

    func startListenIceCandidates(participantId: String) {
        guard let manager = currentUserSubCollections[.iceCandidates] else { return }
        let candidateManager: CandidateManager = manager.subCollectionManager(
            documentID: participantId,
            subCollection: .withParticipant
        )

        iceCandidatesSubCollectionManagers[participantId] = candidateManager

        candidateManager.listenToDocument(
            documentID: currentUserId,
            completion: iceCandidatesHandler(for: participantId)
        )

        candidateManager.readDocument(
            documentID: currentUserId,
            completion: iceCandidatesHandler(for: participantId)
        )
    }

    private func handleSdp(result: Result<SessionDescription, Error>) {
        switch result {
        case let .success(sdp):
            switch sdp.type {
            case .answer, .prAnswer:
                delegate?.didGetAnswer(self, sdp: sdp)
            case .offer:
                delegate?.didGetOffer(self, sdp: sdp)
            case .rollback:
                return
            }
        case let .failure(error):
            delegate?.didGetError(self, error: error)
        }
    }

    private func iceCandidatesHandler(for participantId: String) ->
    (Result<IceCandidateList, Error>) -> Void {
        
        let currentCandidates = oldCandidates[participantId] ?? []
        
        return { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(candidateList):
                let newCandidates = candidateList.iceCandidates
                let candidates = Set(newCandidates).subtracting(currentCandidates)
                candidates.forEach {
                    self.delegate?.didGetCandidate(self, iceCandidate: $0)
                }
                oldCandidates[participantId] = newCandidates
            case let .failure(error):
                delegate?.didGetError(self, error: error)
            }
        }
    }

    func stoplisten(participantId: String) {
        offerManager.stopListenDocument(documentID: participantId)
        answerManager.stopListenDocument(documentID: participantId)
        iceCandidatesManager.stopListenDocument(documentID: participantId)
    }
}
