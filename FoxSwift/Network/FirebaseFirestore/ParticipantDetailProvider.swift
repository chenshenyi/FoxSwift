//
//  ParticipantDetailProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

protocol ParticipantDetailProviderDelegate: AnyObject {
    func didGetOffer(
        _ provider: ParticipantDetailProvider,
        sdp: SessionDescription,
        for: String
    )
    func didGetAnswer(
        _ provider: ParticipantDetailProvider,
        sdp: SessionDescription,
        for: String
    )
    func didGetCandidate(
        _ provider: ParticipantDetailProvider,
        iceCandidate: IceCandidate,
        for: String
    )
    func didGetError(_ provider: ParticipantDetailProvider, error: Error)
}

class ParticipantDetailProvider {
    weak var delegate: ParticipantDetailProviderDelegate?

    typealias SdpManager = FSCollectionManager<SessionDescription, SessionDescription.CodingKeys>

    typealias CandidateManager = FSCollectionManager<IceCandidateList, IceCandidateList.CodingKeys>

    private let localOfferManager: SdpManager

    private let localAnswerManager: SdpManager

    private let localCandidatesManager: CandidateManager

    private var remoteOfferManagers: [String: SdpManager] = [:]

    private var remoteAnswerManagers: [String: SdpManager] = [:]

    private var remoteCandidatesManagers: [String: CandidateManager] = [:]

    private var oldCandidates: [String: [IceCandidate]] = [:]

    private var currentUserId: String {
        Participant.currentUser.id
    }

    let root: (FSCollection, String)

    init(meetingCode: String) {
        let currentUserId = Participant.currentUser.id

        root = (FSCollection.meetingRoom, meetingCode)

        localOfferManager = FSCollectionManager(
            fatherDocument: [
                root,
                (FSCollection.offerSdp, currentUserId)
            ],
            collection: .withParticipant
        )

        localAnswerManager = FSCollectionManager(
            fatherDocument: [
                root,
                (FSCollection.answerSdp, currentUserId)
            ],
            collection: .withParticipant
        )

        localCandidatesManager = FSCollectionManager(
            fatherDocument: [
                root,
                (FSCollection.iceCandidates, currentUserId)
            ],
            collection: .withParticipant
        )
    }

    func send(_ sdp: SessionDescription, to participantId: String) {
        let manager: SdpManager?

        switch sdp.type {
        case .offer:
            manager = localOfferManager
        case .answer, .prAnswer:
            manager = localAnswerManager
        case .rollback:
            fatalError("Can't send such sdp")
        }

        manager?.createDocument(
            data: sdp,
            documentID: participantId
        )
    }

    func newCandidates(to participantId: String) {
        localCandidatesManager.createDocument(
            data: .init(iceCandidates: []),
            documentID: participantId
        )
    }

    func send(_ iceCandidate: IceCandidate, to participantId: String) {
        localCandidatesManager.unionObjects(
            objects: [iceCandidate],
            documentID: participantId,
            field: .iceCandidates
        )
    }

    func startListenOffer(participantId: String) {
        let manager: SdpManager = FSCollectionManager(
            fatherDocument: [
                root,
                (FSCollection.offerSdp, participantId)
            ],
            collection: .withParticipant
        )

        remoteOfferManagers[participantId] = manager

        manager.listenToDocument(
            documentID: currentUserId,
            completion: sdpHandler(for: participantId)
        )
        manager.readDocument(
            documentID: currentUserId,
            completion: sdpHandler(for: participantId)
        )
    }

    func startListenAnswer(participantId: String) {
        let manager: SdpManager = FSCollectionManager(
            fatherDocument: [
                root,
                (FSCollection.answerSdp, participantId)
            ],
            collection: .withParticipant
        )

        remoteAnswerManagers[participantId] = manager

        manager.listenToDocument(
            documentID: currentUserId,
            completion: sdpHandler(for: participantId)
        )
        manager.readDocument(
            documentID: currentUserId,
            completion: sdpHandler(for: participantId)
        )
    }

    func startListenIceCandidates(participantId: String) {
        let manager: CandidateManager = FSCollectionManager(
            fatherDocument: [
                root,
                (FSCollection.iceCandidates, participantId)
            ],
            collection: .withParticipant
        )

        remoteCandidatesManagers[participantId] = manager

        manager.listenToDocument(
            documentID: currentUserId,
            completion: iceCandidatesHandler(for: participantId)
        )
        manager.readDocument(
            documentID: currentUserId,
            completion: iceCandidatesHandler(for: participantId)
        )
    }

    private func sdpHandler(for participantId: String) ->
    (Result<SessionDescription, Error>) -> Void {
        return { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(sdp):
                switch sdp.type {
                case .answer, .prAnswer:
                    delegate?.didGetAnswer(self, sdp: sdp, for: participantId)
                case .offer:
                    delegate?.didGetOffer(self, sdp: sdp, for: participantId)
                case .rollback:
                    return
                }
            case let .failure(error):
                delegate?.didGetError(self, error: error)
            }
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
                    self.delegate?.didGetCandidate(self, iceCandidate: $0, for: participantId)
                }
                oldCandidates[participantId] = newCandidates
            case let .failure(error):
                delegate?.didGetError(self, error: error)
            }
        }
    }

    func stoplisten(participantId: String) {
        remoteOfferManagers[participantId]?.stopListenDocument(documentID: participantId)
        remoteAnswerManagers[participantId]?.stopListenDocument(documentID: participantId)
        remoteCandidatesManagers[participantId]?.stopListenDocument(documentID: participantId)
    }
}
