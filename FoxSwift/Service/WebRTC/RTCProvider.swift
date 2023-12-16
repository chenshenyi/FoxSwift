//
//  RTCProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/20.
//
//

import UIKit
import WebRTC

// MARK: - WebRTCProvider
class RTCProvider: NSObject, FSWebRTCObject {
    // Device media manager
    lazy var cameraCapturer = RTCCameraVideoCapturer(delegate: self)
    lazy var screenCapturer = RTCCameraVideoCapturer(delegate: self)
    let rtcAudioSession = RTCAudioSession.sharedInstance()

    weak var delegate: RTCProviderDelegate?

    let screenSharedManager = ScreenSharedMannager()
    private var peerConnectionProviders: [String: PeerConnectionProvider] = [:]

    func newParticipant(participantId: String) {
        let peerConnectionProvider = PeerConnectionProvider(participantId: participantId)
        peerConnectionProvider.delegate = self
        peerConnectionProviders[participantId] = peerConnectionProvider
    }

    func renderVideo(to view: UIView, for participantId: String, mode: UIView.ContentMode) {
        let renderer = RTCMTLVideoView(frame: .zero)
        renderer.videoContentMode = mode
        renderer.pinTo(view)
        if participantId == Participant.currentUser.id {
            renderLocalVideo(to: renderer)
        } else {
            peerConnectionProviders[participantId]?.renderRemoteVideo(to: renderer)
        }
    }

    func renderScreenSharing(to view: UIView, for participantId: String) {
        let renderer = RTCMTLVideoView(frame: .zero)
        renderer.pinTo(view)
        if participantId == Participant.currentUser.id {
            renderScreenSharing(to: renderer)
        } else {
            peerConnectionProviders[participantId]?.renderRemoteScreenSharing(to: renderer)
        }
    }

    func setRemoteAudio(isEnable: Bool, for participantId: String) {
        peerConnectionProviders[participantId]?.remoteAudioTrack?.isEnabled = isEnable
    }

    func setRemoteVideo(isEnable: Bool, for participantId: String) {
        peerConnectionProviders[participantId]?.remoteVideoTrack?.isEnabled = isEnable
    }

    func sendData(data: Data) {
        peerConnectionProviders.forEach { $0.value.sendData(data) }
    }

    // MARK: - Signaling
    func offer(
        for participantId: String,
        completion: @escaping PeerConnectionProvider.SdpHandler
    ) {
        peerConnectionProviders[participantId]?.offer(completion: completion)
    }

    func answer(
        for participantId: String,
        completion: @escaping PeerConnectionProvider.SdpHandler
    ) {
        peerConnectionProviders[participantId]?.answer(completion: completion)
    }

    func set(
        localSdp sdp: SessionDescription,
        for participantId: String
    ) {
        peerConnectionProviders[participantId]?.set(
            localSdp: sdp.rtcSessionDescription
        ) { error in
            guard let error else { return }
            debugPrint(error.localizedDescription.red)
        }
    }

    func set(
        remoteSdp sdp: SessionDescription,
        for participantId: String
    ) {
        peerConnectionProviders[participantId]?.set(
            remoteSdp: sdp.rtcSessionDescription
        ) { error in
            guard let error else { return }
            debugPrint(error.localizedDescription.red)
        }
    }

    func set(
        remoteCandidate candidate: IceCandidate,
        for participantId: String
    ) {
        peerConnectionProviders[participantId]?.set(
            remoteCandidate: candidate.rtcIceCandidate
        ) { error in
            guard let error else { return }
            debugPrint(error.localizedDescription.red)
        }
    }
}

// MARK: - Camera
extension RTCProvider {
    func startCaptureVideo(camera: AVCaptureDevice.Position = .front) {
        // Get frontCamera from all captureDevice
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices()
            .first(where: { $0.position == camera }) else { return }

        let getWidth: (AVCaptureDevice.Format) -> Int32 = { format in
            CMVideoFormatDescriptionGetDimensions(format.formatDescription).width
        }

        // Find a format with maximum width
        guard let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera)
            .max(by: { getWidth($0) < getWidth($1) }) else { return }

        // Get the highest frame rate
        guard let fps = format.videoSupportedFrameRateRanges
            .max(by: { return $0.maxFrameRate < $1.maxFrameRate }) else { return }

        cameraCapturer.startCapture(
            with: frontCamera,
            format: format,
            fps: Int(fps.maxFrameRate)
        )
        localVideoTrack.isEnabled = true
    }

    func stopCaptureVideo() {
        cameraCapturer.stopCapture()
        localVideoTrack.isEnabled = false
    }

    private func renderLocalVideo(to renderer: RTCVideoRenderer) {
        localVideoTrack.add(renderer)
    }
}

// MARK: - ScreenSharing
extension RTCProvider {
    func startSharingScreen() {
        screenSharedManager.startSharing { [weak self] frame in
            guard let self else { return }
            screenSharingSource.capturer(screenCapturer, didCapture: frame)
        }
        screenSharingTrack.isEnabled = true
    }

    func stopSharingScreen() {
        screenSharedManager.stopSharing()
        screenSharingTrack.isEnabled = false
    }

    private func renderScreenSharing(to renderer: RTCVideoRenderer) {
        screenSharingTrack.add(renderer)
    }
}

// MARK: - Microphone
extension RTCProvider {
    func speakerOn() {
        audioQueue.async { [weak self] in
            guard let self else { return }

            localAudioTrack.isEnabled = true

            rtcAudioSession.lockForConfiguration()
            do {
                try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try rtcAudioSession.overrideOutputAudioPort(.speaker)
                try rtcAudioSession.setActive(true)
            } catch {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            rtcAudioSession.unlockForConfiguration()
        }
    }

    func speakerOff() {
        audioQueue.async { [weak self] in
            guard let self else { return }

            localAudioTrack.isEnabled = false

            rtcAudioSession.lockForConfiguration()
            do {
                try rtcAudioSession.setCategory(.playAndRecord)
                try rtcAudioSession.overrideOutputAudioPort(.none)
                try rtcAudioSession.setActive(false)
            } catch {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            rtcAudioSession.unlockForConfiguration()
        }
    }
}

// MARK: - RTCVideoCapturerDelegate
extension RTCProvider: RTCVideoCapturerDelegate {
    func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {
        if capturer == cameraCapturer {
            videoSource.capturer(capturer, didCapture: frame)
        }
        if capturer == screenCapturer {
            screenSharingSource.capturer(capturer, didCapture: frame)
        }
    }
}
