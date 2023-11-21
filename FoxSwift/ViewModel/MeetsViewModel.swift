//
//  MeetsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

import WebRTC

class MeetsViewModel {
    // MARK: - Network Provider
    private var meetingProvider: MeetingRoomProvider = .init()
    private var participantDetailProvider: ParticipantDetailProvider = .init()

    private var webRTCClient: WebRTCClient?

    // MARK: - Binded Properties
    var activeMeeting: Box<MeetingCellViewModel?> = .init(nil)
    var meetingCode: Box<String> = .init("")


    // MARK: - Init
    init() {
        meetingProvider.delegate = self
        participantDetailProvider.delegate = self
    }

    // MARK: - Meeting
    func createNewCode() {
        meetingProvider.disconnect()
        meetingProvider.create()
    }

    func joinMeet(_ handler: (_ viewModel: MeetingViewModel) -> Void) {
        newRTCClient()

        if meetingCode.value.isEmpty {
            return
        }

        meetingProvider.disconnect()
        meetingProvider.meetingCode = meetingCode.value
        meetingProvider.delegate = self
        meetingProvider.connect()

        let viewModel = MeetingViewModel(meetingCode: meetingCode.value)
        viewModel.webRTCClient = webRTCClient
        handler(viewModel)
    }

    func leaveMeet() {
        meetingProvider.disconnect()
    }

    private func newRTCClient() {
        let iceServers = FSWebRTCConfig.default.webRTCIceServers
        webRTCClient = WebRTCClient(iceServers: iceServers)
        webRTCClient?.delegate = self
    }
}

// MARK: - WebRTCClientDelegate
extension MeetsViewModel: WebRTCClientDelegate {
    func webRTCClient(
        _ client: WebRTCClient,
        didDiscoverLocalCandidate candidate: RTCIceCandidate
    ) {
        participantDetailProvider.send(IceCandidate(from: candidate))
    }

    func webRTCClient(
        _ client: WebRTCClient,
        didChangeConnectionState state: RTCIceConnectionState
    ) {
        print(state.description.yellow)
    }

    func webRTCClient(
        _ client: WebRTCClient,
        didReceiveData data: Data
    ) {}
}

// MARK: - MeetingRoomProviderDelegate
extension MeetsViewModel: MeetingRoomProviderDelegate {
    func meetingRoom(_ provider: MeetingRoomProvider, newMeetingCode: String, createdTime: Int) {
        meetingCode.value = newMeetingCode
    }

    func meetingRoom(
        _ provider: MeetingRoomProvider,
        didRecieveInitial participants: [Participant]
    ) {
        webRTCClient?.offer { [weak self] sdp in
            self?.participantDetailProvider.send(SessionDescription(from: sdp))
            if participants.isEmpty {
                self?.webRTCClient?.set(localSdp: sdp) { _ in }
            }
        }

        participants.forEach { participant in
            participantDetailProvider.startListenIceCandidates(participantId: participant.id)
            participantDetailProvider.startListenOffer(participantId: participant.id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveNew participants: [Participant]) {
        participants.forEach { participant in
            participantDetailProvider.startListenIceCandidates(participantId: participant.id)
            participantDetailProvider.startListenAnswer(participantId: participant.id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveLeft participants: [Participant]) {
        participants.forEach { participant in
            participantDetailProvider.stoplisten(participantId: participant.id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError error: Error) {
        print(error)
    }
}


// MARK: - ParticipantDetailProviderDelegate
extension MeetsViewModel: ParticipantDetailProviderDelegate {
    func didGetOffer(_ provider: ParticipantDetailProvider, sdp: SessionDescription) {
        let rtcSdp = sdp.rtcSessionDescription

        webRTCClient?.set(remoteSdp: rtcSdp) { [weak self] error in
            self?.webRTCClient?.answer { [weak self] sdp in
                guard let self else { return }

                webRTCClient?.set(localSdp: sdp) { _ in }
                participantDetailProvider.send(SessionDescription(from: sdp))
            }
            guard let error else { return }
            print(error.localizedDescription.red)
        }
    }

    func didGetAnswer(_ provider: ParticipantDetailProvider, sdp: SessionDescription) {
        let rtcSdp = sdp.rtcSessionDescription

        webRTCClient?.set(remoteSdp: rtcSdp) { error in
            guard let error else { return }
            print(error.localizedDescription.red)
        }
    }

    func didGetCandidate(_ provider: ParticipantDetailProvider, iceCandidate: IceCandidate) {
        let rtcIceCandidate = iceCandidate.rtcIceCandidate
        webRTCClient?.set(remoteCandidate: rtcIceCandidate) { error in
            guard let error else { return }
            print(error.localizedDescription.red)
        }
    }

    func didGetError(_ provider: ParticipantDetailProvider, error: Error) {
        print(error.localizedDescription.red)
    }
}
