//
//  RTCProviderDelegate.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/21.
//

import WebRTC

// MARK: - WebRTCProviderDelegate
protocol RTCProviderDelegate: AnyObject {
    func rtcProvider(
        _ provider: RTCProvider,
        didDiscoverLocalCandidate candidate: IceCandidate,
        for candidateId: String
    )

    func rtcProvider(
        _ provider: RTCProvider,
        didRemoveCandidates candidates: [IceCandidate],
        for candidateId: String
    )

    func rtcProvider(
        _ provider: RTCProvider,
        didReceiveMessageWith data: Data,
        for candidateId: String
    )
}


// MARK: - PeerConnectionProviderDelegate
extension RTCProvider: PeerConnectionProviderDelegate {
    func peerConnectionProvider(
        _ provider: PeerConnectionProvider,
        didDiscoverLocalCandidate candidate: RTCIceCandidate
    ) {
        delegate?.rtcProvider(
            self,
            didDiscoverLocalCandidate: IceCandidate(from: candidate),
            for: provider.participantId
        )
    }

    func peerConnectionProvider(
        _ provider: PeerConnectionProvider,
        didRemoveCandidates candidates: [RTCIceCandidate]
    ) {
        delegate?.rtcProvider(
            self,
            didRemoveCandidates: candidates.map({ rtcIceCandidate in
                IceCandidate(from: rtcIceCandidate)
            }),
            for: provider.participantId
        )
    }

    func peerConnectionProvider(
        _ provider: PeerConnectionProvider,
        didReceiveMessageWith buffer: RTCDataBuffer
    ) {
        delegate?.rtcProvider(
            self,
            didReceiveMessageWith: buffer.data,
            for: provider.participantId
        )
    }
}
