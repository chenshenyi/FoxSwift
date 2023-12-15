//
//  RTCMessage.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/20.
//

import Foundation

enum RTCMessage {
    case sdp(SessionDescription)
    case candidate(IceCandidate)
}

extension RTCMessage: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case String(describing: SessionDescription.self):
            self = try .sdp(container.decode(SessionDescription.self, forKey: .payload))

        case String(describing: IceCandidate.self):
            self = try .candidate(container.decode(IceCandidate.self, forKey: .payload))

        default:
            throw DecodeError.unknownType
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .sdp(sessionDescription):
            try container.encode(sessionDescription, forKey: .payload)
            try container.encode(String(describing: SessionDescription.self), forKey: .type)

        case let .candidate(iceCandidate):
            try container.encode(iceCandidate, forKey: .payload)
            try container.encode(String(describing: IceCandidate.self), forKey: .type)
        }
    }

    enum DecodeError: Error {
        case unknownType
    }

    enum CodingKeys: String, CodingKey {
        case type, payload
    }
}
