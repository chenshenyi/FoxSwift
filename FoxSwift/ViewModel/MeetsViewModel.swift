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
    private lazy var participantDetailProvider: ParticipantDetailProvider? =
        .init(meetingRoomProvider: meetingProvider)

    private var rtcProvider: RTCProvider?

    // MARK: - Binded Properties
    var activeMeeting: Box<MeetingCellViewModel?> = .init(nil)
    var meetingCode: Box<String> = .init("")


    // MARK: - Init
    init() {
        meetingProvider.delegate = self
        participantDetailProvider?.delegate = self
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
        viewModel.rtcProvider = rtcProvider
        handler(viewModel)
    }

    func leaveMeet() {
        meetingProvider.disconnect()
    }

    private func newRTCClient() {
        rtcProvider = .init()
        rtcProvider?.delegate = self
    }
}


// MARK: - RTCProvider
extension MeetsViewModel: RTCProviderDelegate {
    func rtcProvider(
        _ provider: RTCProvider,
        didDiscoverLocalCandidate candidate: IceCandidate,
        for candidateId: String
    ) {
        participantDetailProvider?.send(candidate, to: candidateId)
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
extension MeetsViewModel: MeetingRoomProviderDelegate {
    func meetingRoom(_ provider: MeetingRoomProvider, newMeetingCode: String, createdTime: Int) {
        meetingCode.value = newMeetingCode
    }

    func meetingRoom(
        _ provider: MeetingRoomProvider,
        didRecieveInitial participants: [Participant]
    ) {
        participants.map(\.id).forEach { id in
            rtcProvider?.newParticipant(participantId: id)

            participantDetailProvider?.startListenIceCandidates(participantId: id)
            participantDetailProvider?.startListenOffer(participantId: id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveNew participants: [Participant]) {
        participants.map(\.id).forEach { id in
            rtcProvider?.newParticipant(participantId: id)

            rtcProvider?.offer(for: id) { [weak self] sdpResult in
                guard let self else { return }

                switch sdpResult {
                case let .success(sdp):
                    rtcProvider?.set(localSdp: sdp, for: id)
                    participantDetailProvider?.send(sdp, to: id)
                case let .failure(error):
                    print(error.localizedDescription.red)
                }
            }

            participantDetailProvider?.startListenIceCandidates(participantId: id)
            participantDetailProvider?.startListenAnswer(participantId: id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveLeft participants: [Participant]) {
        participants.forEach { participant in
            participantDetailProvider?.stoplisten(participantId: participant.id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError error: Error) {
        print(error.localizedDescription.red)
    }
}


extension MeetsViewModel: ParticipantDetailProviderDelegate {
    func didGetOffer(
        _ provider: ParticipantDetailProvider,
        sdp: SessionDescription,
        for id: String
    ) {
        rtcProvider?.set(remoteSdp: sdp, for: id)
        rtcProvider?.answer(for: id) { [weak self] sdpResult in
            guard let self else { return }

            switch sdpResult {
            case let .success(sdp):
                rtcProvider?.set(localSdp: sdp, for: id)
                participantDetailProvider?.send(sdp, to: id)
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
        rtcProvider?.set(remoteSdp: sdp, for: id)
    }

    func didGetCandidate(
        _ provider: ParticipantDetailProvider,
        iceCandidate: IceCandidate,
        for id: String
    ) {
        rtcProvider?.set(remoteCandidate: iceCandidate, for: id)
    }

    func didGetError(_ provider: ParticipantDetailProvider, error: Error) {
        print(error.localizedDescription.red)
    }
}
