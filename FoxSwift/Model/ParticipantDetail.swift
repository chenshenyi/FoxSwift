//
//  ParticipantDetail.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import Foundation

struct ParticipantDetail: Codable {
    var offerSdp: SessionDescription?
    var answerSdp: SessionDescription?
    var iceCandidates: [IceCandidate] = []

    enum CodingKeys: CodingKey {
        case offerSdp
        case answerSdp
        case iceCandidates
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let offerData = try container.decodeIfPresent(Data.self, forKey: .offerSdp) {
            offerSdp = try JSONDecoder().decode(SessionDescription.self, from: offerData)
        }

        if let answerData = try container.decodeIfPresent(Data.self, forKey: .answerSdp) {
            answerSdp = try JSONDecoder().decode(SessionDescription.self, from: answerData)
        }

        let iceCandidatesData = try container.decode([Data].self, forKey: .iceCandidates)
        iceCandidates = try iceCandidatesData.map { data in
            try JSONDecoder().decode(IceCandidate.self, from: data)
        }
    }
}
