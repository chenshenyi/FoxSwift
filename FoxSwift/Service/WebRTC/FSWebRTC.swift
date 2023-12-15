//
//  FSWebRTC.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/21.
//

import WebRTC

/// Static Properties of All WebRTC Objects
///
/// RTCProvider and PeerConnectionProvider are tightly coupling objects.
/// This enum is just use for store static properties of them.
enum FSWebRTC {
    static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
    }()

    static let rtcConfig: RTCConfiguration = {
        let config = RTCConfiguration()
        let iceServers = FSWebRTCConfig.default.webRTCIceServers

        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually

        return config
    }()

    static let mandatoryConstraints = RTCMediaConstraints(
        mandatoryConstraints: [
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
        ],
        optionalConstraints: nil
    )

    static let optionalConstraints = RTCMediaConstraints(
        mandatoryConstraints: nil,
        optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
    )

    static let audioSource = {
        let audioConstrains = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )

        return factory.audioSource(with: audioConstrains)
    }()

    static let videoSource = factory.videoSource()

    static let localAudioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")

    static let localVideoTrack = factory.videoTrack(with: videoSource, trackId: "video0")

    static let screenSharingSource = factory.videoSource(forScreenCast: true)

    static let screenSharingTrack = factory.videoTrack(with: screenSharingSource, trackId: "video0")

    static let audioQueue = DispatchQueue(label: "audio")
}

protocol FSWebRTCObject: AnyObject {}

extension FSWebRTCObject {
    var factory: RTCPeerConnectionFactory {
        FSWebRTC.factory
    }

    var rtcConfig: RTCConfiguration {
        FSWebRTC.rtcConfig
    }

    var mandatoryConstraints: RTCMediaConstraints {
        FSWebRTC.mandatoryConstraints
    }

    var optionalConstraints: RTCMediaConstraints {
        FSWebRTC.optionalConstraints
    }

    var audioSource: RTCAudioSource {
        FSWebRTC.audioSource
    }

    var videoSource: RTCVideoSource {
        FSWebRTC.videoSource
    }

    var localAudioTrack: RTCAudioTrack {
        FSWebRTC.localAudioTrack
    }

    var localVideoTrack: RTCVideoTrack {
        FSWebRTC.localVideoTrack
    }

    var screenSharingSource: RTCVideoSource {
        FSWebRTC.screenSharingSource
    }

    var screenSharingTrack: RTCVideoTrack {
        FSWebRTC.screenSharingTrack
    }

    var audioQueue: DispatchQueue {
        FSWebRTC.audioQueue
    }
}
