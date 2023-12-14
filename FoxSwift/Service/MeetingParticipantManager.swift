//
//  MeetingRoomFlowProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/14.
//

import Foundation
import UIKit

protocol MeetingParticipantManagerDelegate: AnyObject {
    func meetingRoom(
        _ manager: MeetingParticipantManager,
        didRecieveInitial participants: [Participant]
    )

    func meetingRoom(
        _ manager: MeetingParticipantManager,
        didRecieveNew participants: [Participant]
    )

    func meetingRoom(
        _ manager: MeetingParticipantManager,
        didRecieveLeft participants: [Participant]
    )
}

class MeetingParticipantManager {
    // MARK: Provider
    private let meetingProvider: MeetingRoomProvider
    private let participantDetailProvider: ParticipantDetailProvider
    private let rtcProvider = RTCProvider()

    var meetingCode: MeetingRoom.MeetingCode
    var participants: [Participant] = []
    var delegate: MeetingParticipantManagerDelegate?

    init(meetingCode: String) {
        self.meetingCode = meetingCode

        meetingProvider = .init(meetingCode: meetingCode)
        participantDetailProvider = .init(meetingCode: meetingCode)
    }

    func setupProvider() {
        meetingProvider.delegate = self
        participantDetailProvider.delegate = self
        rtcProvider.delegate = self
    }

    func connect() {
        meetingProvider.connect()
    }

    func leave() {
        meetingProvider.disconnect()
    }

    // MARK: - Fetch video
    func fetchVideo(into view: UIView, for participant: Participant) {
        if participant.id == Participant.currentUser.id {
            rtcProvider.startCaptureVideo()
        }
        rtcProvider.renderVideo(to: view, for: participant.id, mode: .scaleAspectFill)
        view.layoutIfNeeded()
    }

    // FIXME: incorrect open
    func startScreenSharing() {
        rtcProvider.startSharingScreen()
    }

    func stopScreenSharing() {
        rtcProvider.startCaptureVideo()
    }

    // MARK: - Functional Buttons
    func turnOffMic() {
        rtcProvider.speakerOff()
    }

    func turnOnMic() {
        rtcProvider.speakerOn()
    }

    func turnOnAudio() {
        participants.map(\.id).forEach { id in
            rtcProvider.setRemoteAudio(isEnable: true, for: id)
        }
    }

    func turnOffAudio() {
        participants.map(\.id).forEach { id in
            rtcProvider.setRemoteAudio(isEnable: false, for: id)
        }
    }

    func turnOnCamera() {
        rtcProvider.startCaptureVideo()
    }

    func turnOffCamera() {
        rtcProvider.stopCaptureVideo()
    }
}

// MARK: - RTCProvider
extension MeetingParticipantManager: RTCProviderDelegate {
    func rtcProvider(
        _ provider: RTCProvider,
        didDiscoverLocalCandidate candidate: IceCandidate,
        for candidateId: String
    ) {
        participantDetailProvider.send(candidate, to: candidateId)
    }

    func rtcProvider(
        _ provider: RTCProvider,
        didRemoveCandidates candidates: [IceCandidate],
        for candidateId: String
    ) {
        print("Did Remove \(candidates.count) candidates".red)
    }

    func rtcProvider(
        _ provider: RTCProvider,
        didReceiveMessageWith data: Data,
        for candidateId: String
    ) {}
}

// MARK: - MeetingRoomProviderDelegate
extension MeetingParticipantManager: MeetingRoomProviderDelegate {
    func meetingRoom(
        _ provider: MeetingRoomProvider,
        didRecieveInitial participants: [Participant]
    ) {
        participants.map(\.id).forEach { id in
            rtcProvider.newParticipant(participantId: id)

            participantDetailProvider.newCandidates(to: id)
            participantDetailProvider.startListenIceCandidates(participantId: id)
            participantDetailProvider.startListenOffer(participantId: id)
        }

        self.participants += participants
        
        delegate?.meetingRoom(self, didRecieveInitial: participants)
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveNew participants: [Participant]) {
        participants.map(\.id).forEach { id in
            rtcProvider.newParticipant(participantId: id)
            participantDetailProvider.newCandidates(to: id)

            rtcProvider.offer(for: id) { [weak self] sdpResult in
                guard let self else { return }

                switch sdpResult {
                case let .success(sdp):
                    rtcProvider.set(localSdp: sdp, for: id)
                    participantDetailProvider.send(sdp, to: id)
                case let .failure(error):
                    print(error.localizedDescription.red)
                }
            }

            participantDetailProvider.startListenIceCandidates(participantId: id)
            participantDetailProvider.startListenAnswer(participantId: id)
        }

        self.participants += participants
        
        delegate?.meetingRoom(self, didRecieveNew: participants)
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveLeft participants: [Participant]) {
        participants.forEach { participant in
            participantDetailProvider.stoplisten(participantId: participant.id)
            self.participants.removeAll { participant == $0 }
        }
        
        delegate?.meetingRoom(self, didRecieveLeft: participants)
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError error: Error) {
        print(error.localizedDescription.red)
    }
}

// MARK: Participant Detail Provider Delegate
extension MeetingParticipantManager: ParticipantDetailProviderDelegate {
    func didGetOffer(
        _ provider: ParticipantDetailProvider,
        sdp: SessionDescription,
        for id: String
    ) {
        rtcProvider.set(remoteSdp: sdp, for: id)
        rtcProvider.answer(for: id) { [weak self] sdpResult in
            guard let self else { return }

            switch sdpResult {
            case let .success(sdp):
                rtcProvider.set(localSdp: sdp, for: id)
                participantDetailProvider.send(sdp, to: id)
            case let .failure(error):
                print(error.localizedDescription.red)
            }
        }
    }

    func didGetAnswer(
        _ provider: ParticipantDetailProvider,
        sdp: SessionDescription,
        for id: String
    ) {
        rtcProvider.set(remoteSdp: sdp, for: id)
    }

    func didGetCandidate(
        _ provider: ParticipantDetailProvider,
        iceCandidate: IceCandidate,
        for id: String
    ) {
        rtcProvider.set(remoteCandidate: iceCandidate, for: id)
    }

    func didGetError(_ provider: ParticipantDetailProvider, error: Error) {
        print(error.localizedDescription.red)
    }
}
