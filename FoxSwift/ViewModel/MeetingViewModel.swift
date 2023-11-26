//
//  MeetingViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import UIKit

class MeetingViewModel {
    // MARK: - Network Provider
    private let meetingProvider: MeetingRoomProvider
    private let participantDetailProvider: ParticipantDetailProvider
    private let messageProvider: MessageProvider
    private let rtcProvider: RTCProvider

    // MARK: - Binded Properties
    var activeMeeting: Box<MeetingCellViewModel?> = .init(nil)
    var meetingCode: Box<String> = .init("")
    var participants: DiffBox<Participant> = .init([.currentUser])
    var messages: Box<[FSMessage]> = .init([])

    init(meetingCode: String) {
        self.meetingCode = .init(meetingCode)

        meetingProvider = .init(meetingCode: meetingCode)
        participantDetailProvider = .init(meetingCode: meetingCode)
        messageProvider = .init(meetingCode: meetingCode)
        rtcProvider = .init()

        meetingProvider.delegate = self
        participantDetailProvider.delegate = self
        rtcProvider.delegate = self

        meetingProvider.connect()
        messageProvider.startListen { [weak self] message in
            self?.messages.value.append(message)
        }
    }

    func fetchRemoteVideo(into view: UIView, for participant: Participant) {
        if participant.id == Participant.currentUser.id {
            rtcProvider.startCaptureVideo()
        }
        rtcProvider.renderVideo(to: view, for: participant.id, mode: .scaleAspectFill)
        view.layoutIfNeeded()
    }

    func fetchLocalVideo(into view: UIView) {
        rtcProvider.startCaptureVideo()
        rtcProvider.renderVideo(to: view, for: Participant.currentUser.id, mode: .scaleAspectFill)
        view.layoutIfNeeded()
    }

    func leaveMeet() {
        meetingProvider.disconnect()
        messageProvider.stopListenMessage()
    }

    func sendMessage(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        let message = FSMessage(data: data, author: .currentUser, type: .text)

        messageProvider.send(message: message)
    }


    // MARK: - Functional Buttons
    func turnOffMic() {
        rtcProvider.speakerOff()
    }

    func turnOnMic() {
        rtcProvider.speakerOn()
    }

    func turnOnAudio() {
        participants.value
            .map(\.id)
            .forEach { id in
                rtcProvider.setRemoteAudio(isEnable: true, for: id)
            }
    }

    func turnOffAudio() {
        participants.value
            .map(\.id)
            .forEach { id in
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
extension MeetingViewModel: RTCProviderDelegate {
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
extension MeetingViewModel: MeetingRoomProviderDelegate {
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

        self.participants.value += participants
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

        self.participants.value += participants
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveLeft participants: [Participant]) {
        participants.forEach { participant in
            participantDetailProvider.stoplisten(participantId: participant.id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError error: Error) {
        print(error.localizedDescription.red)
    }
}


extension MeetingViewModel: ParticipantDetailProviderDelegate {
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
