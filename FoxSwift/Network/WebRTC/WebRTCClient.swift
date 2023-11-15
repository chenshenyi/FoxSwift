//
//  WebRTCClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

final class WebRTCClient: NSObject {
    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
    }()

    weak var delegate: WebRTCClientDelegate?
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [
        kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
    ]
    private var videoCapturer: RTCVideoCapturer?

    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?

    private var localDataChannel: RTCDataChannel?
    var remoteDataChannel: RTCDataChannel?

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }

    required init(iceServers: [String]) {
        // MARK: Initial Configuration
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]

        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan

        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually


        // MARK: Init constraint
        // Define media constraints. DtlsSrtpKeyAgreement is required to be true to be able to connect with web browsers.
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
        )

        // MARK: set peerConnection with config and constraints
        guard let peerConnection = WebRTCClient.factory.peerConnection(
            with: config, constraints: constraints, delegate: nil
        ) else {
            fatalError("Could not create new RTCPeerConnection")
        }

        self.peerConnection = peerConnection

        super.init()
        createMediaSenders()
        configureAudioSession()
        self.peerConnection.delegate = self
    }

    // MARK: Signaling
    /// Call peerConnection offer
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(
            mandatoryConstraints: mediaConstrains,
            optionalConstraints: nil
        )
        peerConnection.offer(for: constrains) { sdp, _ in
            guard let sdp else {
                return
            }

            self.peerConnection.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }

    /// Call peerConnection answer
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(
            mandatoryConstraints: mediaConstrains,
            optionalConstraints: nil
        )
        peerConnection.answer(for: constrains) { sdp, _ in
            guard let sdp else {
                return
            }

            self.peerConnection.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }

    /// Set peerConnection Remote Sdp
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }

    /// Set peerConnection remote Candidate
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> Void) {
        peerConnection.add(remoteCandidate, completionHandler: completion)
    }

    // MARK: Media
    /// Call RTCCameraVideoCapturer start capture
    /// choose highest res and fps
    ///
    /// add the renderer to localVideoTrack
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer else {
            return
        }

        guard
            let frontCamera = (
                RTCCameraVideoCapturer.captureDevices()
                    .first { $0.position == .front }
            ),

            // choose highest res
            let format = (
                RTCCameraVideoCapturer.supportedFormats(for: frontCamera)
                    .sorted { format1, format2 -> Bool in
                        let width1 = CMVideoFormatDescriptionGetDimensions(
                            format1.formatDescription
                        )
                        .width
                        let width2 = CMVideoFormatDescriptionGetDimensions(
                            format2.formatDescription
                        )
                        .width
                        return width1 < width2
                    }
            ).last,

            // choose highest fps
            let fps = (
                format.videoSupportedFrameRateRanges
                    .sorted { return $0.maxFrameRate < $1.maxFrameRate }.last
            )
        else {
            return
        }

        capturer.startCapture(
            with: frontCamera,
            format: format,
            fps: Int(fps.maxFrameRate)
        )

        localVideoTrack?.add(renderer)
    }

    /// add the renderer to remoteVideoTrack
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        remoteVideoTrack?.add(renderer)
    }

    ///  set RTCAudioSession voice chat
    private func configureAudioSession() {
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat)
        } catch {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
    }

    /// add audioTrack to peerConnection and set id = "stream"
    ///
    /// set localVideoTrack to newVideoTrack
    /// add audioTrack to peerConnection and set id = "stream"
    /// set remoteVideoTrack from peerConnection transceivers
    ///
    /// set localDataChannel
    private func createMediaSenders() {
        let streamId = "stream"

        // Audio
        let audioTrack = createAudioTrack()
        peerConnection.add(audioTrack, streamIds: [streamId])

        // Video
        let videoTrack = createVideoTrack()
        localVideoTrack = videoTrack
        peerConnection.add(videoTrack, streamIds: [streamId])
        remoteVideoTrack = peerConnection.transceivers.first { $0.mediaType == .video }?.receiver
            .track as? RTCVideoTrack

        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            localDataChannel = dataChannel
        }
    }

    /// return audioTrack with track ID: "audio0"
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }

    /// return videoTrack with track ID: "video0"
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()

        #if targetEnvironment(simulator)
            videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
            videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif

        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }

    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConnection.dataChannel(
            forLabel: "WebRTCData",
            configuration: config
        ) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }

    /// send Data to remoteDataChannel
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        remoteDataChannel?.sendData(buffer)
    }
}

extension WebRTCClient {
    /// Enability peercConnection.transeivers
    ///
    /// - Parameters:
    ///   - type: Downcase `RTCMediaStreamTrack` to specific type.
    ///   - isEnabled: set track.isEnabled
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: - Video control
extension WebRTCClient {
    func hideVideo() {
        setVideoEnabled(false)
    }

    func showVideo() {
        setVideoEnabled(true)
    }

    private func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled)
    }
}

// MARK: - Audio control
extension WebRTCClient {
    func muteAudio() {
        setAudioEnabled(false)
    }

    func unmuteAudio() {
        setAudioEnabled(true)
    }

    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        audioQueue.async { [weak self] in
            guard let self else {
                return
            }

            rtcAudioSession.lockForConfiguration() // lock for config
            do {
                try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try rtcAudioSession.overrideOutputAudioPort(.none)
            } catch {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            rtcAudioSession.unlockForConfiguration() // unlock
        }
    }

    // Force speaker
    func speakerOn() {
        audioQueue.async { [weak self] in
            guard let self else {
                return
            }

            rtcAudioSession.lockForConfiguration() // lock for config
            do {
                try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try rtcAudioSession.overrideOutputAudioPort(.speaker)
                try rtcAudioSession.setActive(true)
            } catch {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            rtcAudioSession.unlockForConfiguration() // unlock
        }
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }

    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}
