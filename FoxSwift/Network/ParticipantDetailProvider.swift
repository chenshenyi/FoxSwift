//
//  ParticipantDetailProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

struct ParticipantDetail: Codable {
    var sdp: SessionDescription?
    var iceCandidates: [IceCandidate] = []

    enum Field: String, FSField {
        case sdp
        case iceCandidates
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let sdpData = try container.decodeIfPresent(Data.self, forKey: .sdp) {
            sdp = try JSONDecoder().decode(SessionDescription.self, from: sdpData)
        }

        let iceCandidatesData = try container.decode([Data].self, forKey: .iceCandidates)
        iceCandidates = try iceCandidatesData.map { data in
            try JSONDecoder().decode(IceCandidate.self, from: data)
        }
    }
}

protocol ParticipantDetailProviderDelegate: AnyObject {
    func didReceive(_ provider: ParticipantDetailProvider, participantDetail: ParticipantDetail)
}

class ParticipantDetailProvider {
    private let collectionManager = FSCollectionManager(collection: .participantDetail)
    var delegate: ParticipantDetailProviderDelegate?

    private var currentUser: Participant {
        Participant.currentUser
    }

    init() {
        collectionManager.createDocument(data: ParticipantDetail(), documentID: currentUser.id)
    }

    func send(sdp: SessionDescription) {
        let data = try? JSONEncoder().encode(sdp)
        guard let data else { return }

        collectionManager.updateData(
            data: data,
            documentID: currentUser.id,
            field: ParticipantDetail.Field.sdp
        )
    }

    func send(iceCandidate: IceCandidate) {
        let data = try? JSONEncoder().encode(iceCandidate)

        guard let data else { return }

        collectionManager.unionSerialObjects(
            serialObjects: [data],
            documentID: currentUser.id,
            field: ParticipantDetail.Field.iceCandidates
        )
    }

    func read(participantId: String) {
        collectionManager.readDocument(
            asType: ParticipantDetail.self,
            documentID: participantId
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(participantDetail):
                delegate?.didReceive(self, participantDetail: participantDetail)
            case .failure:
                break
            }
        }
    }
}
