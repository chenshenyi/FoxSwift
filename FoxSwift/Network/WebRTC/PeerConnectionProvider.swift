//
//  PeerConnectionProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/21.
//

import WebRTC

// MARK: - PeerConnectionProvider
/// This object should only call by RTCProvider
class PeerConnectionProvider: NSObject, FSWebRTCObject {
    var participantId: String
    weak var delegate: PeerConnectionProviderDelegate?

    lazy var peerConnection: RTCPeerConnection = {
        guard let peerConnection = factory.peerConnection(
            with: rtcConfig,
            constraints: optionalConstraints,
            delegate: self
        ) else {
            fatalError("Cannot create peerConnection".red)
        }
        return peerConnection
    }()

    // MARK: Remote Tracks
    var remoteVideoTrack: RTCVideoTrack?
    var remoteAudioTrack: RTCAudioTrack?

    // MARK: Data Channel
    var localDataChannel: RTCDataChannel?
    var remoteDataChannel: RTCDataChannel?

    // MARK: - Init
    init(participantId: String) {
        self.participantId = participantId
        super.init()

        addLocalTracks()
        addRemoteTracks()
        createDataChannel()
    }
}

// MARK: - Media Track and Data Channel
extension PeerConnectionProvider {
    private func addLocalTracks() {
        let streamId = "Stream"

        peerConnection.add(localAudioTrack, streamIds: [streamId])
        peerConnection.add(localVideoTrack, streamIds: [streamId])
    }

    private func addRemoteTracks() {
        remoteAudioTrack = peerConnection.transceivers.first { $0.mediaType == .audio }?
            .receiver
            .track as? RTCAudioTrack

        remoteVideoTrack = peerConnection.transceivers.first { $0.mediaType == .video }?
            .receiver
            .track as? RTCVideoTrack
    }

    private func createDataChannel() {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConnection.dataChannel(
            forLabel: "WebRTCData",
            configuration: config
        ) else {
            debugPrint("Warning: Couldn't create data channel.")
            return
        }

        dataChannel.delegate = self
        localDataChannel = dataChannel
    }

    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        remoteDataChannel?.sendData(buffer)
    }

    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        remoteVideoTrack?.add(renderer)
    }
}

// MARK: - Signaling
extension PeerConnectionProvider {
    typealias SdpHandler = (_ sdpResult: Result<SessionDescription, Error>) -> Void

    func offer(completion: @escaping SdpHandler) {
        peerConnection.offer(for: mandatoryConstraints) { sdp, error in
            if let error {
                completion(.failure(error))
            }

            if let sdp {
                completion(.success(SessionDescription(from: sdp)))
            }
        }
    }

    func answer(completion: @escaping SdpHandler) {
        peerConnection.answer(for: mandatoryConstraints) { sdp, error in
            if let error {
                completion(.failure(error))
            }

            if let sdp {
                completion(.success(SessionDescription(from: sdp)))
            }
        }
    }

    typealias ErrorHandler = (_ error: Error?) -> Void

    func set(localSdp: RTCSessionDescription, completion: @escaping ErrorHandler) {
        peerConnection.setLocalDescription(localSdp, completionHandler: completion)
    }

    func set(remoteSdp: RTCSessionDescription, completion: @escaping ErrorHandler) {
        peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }

    func set(remoteCandidate: RTCIceCandidate, completion: @escaping ErrorHandler) {
        peerConnection.add(remoteCandidate, completionHandler: completion)
    }
}
