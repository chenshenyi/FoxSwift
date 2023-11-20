//
//  SessionDescription.swift
//  WebRTC-Demo
//
//  Created by Stasel on 20/02/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation
import WebRTC

/// Wrapping RTCType and SessionDescription(SDP)
///
/// - Important: SDP is the data we need to exchange to the other peer through signal server

/// This enum is a swift wrapper over `RTCSdpType` for easy encode and decode
enum SdpType: String, Codable {
    case offer, prAnswer, answer, rollback

    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer: return .offer
        case .answer: return .answer
        case .prAnswer: return .prAnswer
        case .rollback: return .rollback
        }
    }
}

/// This struct is a swift wrapper over `RTCSessionDescription` for easy encode and decode
struct SessionDescription: Codable {
    let sdp: String
    let type: SdpType


    enum CodingKeys: CodingKey {
        case sdp, type
    }

    init() {
        sdp = ""
        type = .prAnswer
    }

    init(from rtcSessionDescription: RTCSessionDescription) {
        sdp = rtcSessionDescription.sdp

        switch rtcSessionDescription.type {
        case .offer: type = .offer
        case .prAnswer: type = .prAnswer
        case .answer: type = .answer
        case .rollback: type = .rollback
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }

    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: type.rtcSdpType, sdp: sdp)
    }
}
