//
//  PeerConnectionDelegate.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/21.
//

import WebRTC

// MARK: Delegate
protocol PeerConnectionProviderDelegate: AnyObject {
    func peerConnectionProvider(
        _ provider: PeerConnectionProvider,
        didDiscoverLocalCandidate candidate: RTCIceCandidate
    )
    func peerConnectionProvider(
        _ provider: PeerConnectionProvider,
        didRemoveCandidates candidates: [RTCIceCandidate]
    )
    func peerConnectionProvider(
        _ provider: PeerConnectionProvider,
        didReceiveMessageWith buffer: RTCDataBuffer
    )
}

// MARK: - RTCDataChannelDelegate
extension PeerConnectionProvider: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("Data channel did change state: \(dataChannel.readyState)".blue)
    }

    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        delegate?.peerConnectionProvider(self, didReceiveMessageWith: buffer)
    }
}

extension PeerConnectionProvider: RTCPeerConnectionDelegate {
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange stateChanged: RTCSignalingState
    ) {
        debugPrint("peerConnection new signaling state: \(stateChanged.description)".green)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream".green)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream".green)
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate".green)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
        debugPrint("peerConnection new connection state: \(newState.description)".green)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {
        debugPrint("peerConnection new gathering state: \(newState.description)".green)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didGenerate candidate: RTCIceCandidate
    ) {
        debugPrint("peerConnection did generate candidate".green)
        delegate?.peerConnectionProvider(self, didDiscoverLocalCandidate: candidate)
    }

    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove candidates: [RTCIceCandidate]
    ) {
        debugPrint("peerConnection did remove candidate(s)".green)
        delegate?.peerConnectionProvider(self, didRemoveCandidates: candidates)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel".green)
        remoteDataChannel = dataChannel
    }
}
