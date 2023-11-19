//
//  ParticipantDetail.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
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
