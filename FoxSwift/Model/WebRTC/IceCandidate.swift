//
//  IceCandidate.swift
//  WebRTC-Demo
//
//  Created by Stasel on 20/02/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation
import WebRTC


/// IceCandidate help the server to find where the client is

/// This struct is a swift wrapper over `RTCIceCandidate` for easy encode and decode
struct IceCandidate: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?

    init(from iceCandidate: RTCIceCandidate) {
        sdpMLineIndex = iceCandidate.sdpMLineIndex
        sdpMid = iceCandidate.sdpMid
        sdp = iceCandidate.sdp
    }

    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}
