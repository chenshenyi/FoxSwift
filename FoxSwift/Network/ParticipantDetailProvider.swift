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
    private let offerManager = FSCollectionManager<
        SessionDescription,
        SessionDescription.CodingKeys
    >(collection: .offerSdp)

    private let answerManager = FSCollectionManager<
        SessionDescription,
        SessionDescription.CodingKeys
    >(collection: .answerSdp)

    private let iceCandidatesManager = FSCollectionManager<
        IceCandidateList,
        IceCandidateList.CodingKeys
    >(collection: .iceCandidates)

    weak var delegate: ParticipantDetailProviderDelegate?

    var oldCandidates: [IceCandidate] = []

    private var currentUserId: String {
        Participant.currentUser.id
    }

    init() {
        offerManager.createDocument(data: SessionDescription(), documentID: currentUserId)
        answerManager.createDocument(data: SessionDescription(), documentID: currentUserId)
        iceCandidatesManager.createDocument(data: IceCandidateList(), documentID: currentUserId)
    }

    func send(_ sdp: SessionDescription) {
        let manager: FSCollectionManager<
            SessionDescription,
            SessionDescription.CodingKeys
        >

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
            documentID: currentUserId
        )
    }

    func send(_ iceCandidate: IceCandidate) {
        iceCandidatesManager.unionObjects(
            objects: [iceCandidate],
            documentID: currentUserId,
            field: .iceCandidates
        )
    }

    func startListenOffer(participantId: String) {
        offerManager.listenToDocument(documentID: participantId, completion: handleSdp)
        offerManager.readDocument(documentID: participantId, completion: handleSdp)
    }

    func startListenAnswer(participantId: String) {
        answerManager.listenToDocument(documentID: participantId, completion: handleSdp)
        answerManager.readDocument(documentID: participantId, completion: handleSdp)
    }

    func startListenIceCandidates(participantId: String) {
        iceCandidatesManager.listenToDocument(
            documentID: participantId,
            completion: handleIceCandidates
        )
        iceCandidatesManager.readDocument(
            documentID: participantId,
            completion: handleIceCandidates
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

    private func handleIceCandidates(result: Result<IceCandidateList, Error>) {
        switch result {
        case let .success(candidateList):
            let newCandidates = candidateList.iceCandidates
            let candidates = Set(newCandidates).subtracting(oldCandidates)
            candidates.forEach {
                self.delegate?.didGetCandidate(self, iceCandidate: $0)
            }
            oldCandidates = newCandidates
        case let .failure(error):
            delegate?.didGetError(self, error: error)
        }
    }

    func stoplisten(participantId: String) {
        offerManager.stopListenDocument(documentID: participantId)
        answerManager.stopListenDocument(documentID: participantId)
        iceCandidatesManager.stopListenDocument(documentID: participantId)
    }
}
