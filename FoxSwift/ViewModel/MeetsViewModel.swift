//
//  MeetsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import Foundation

import WebRTC

class MeetsViewModel {
    private var meetingProvider: MeetingRoomProvider = .init()
    private var participantDetailProvider: ParticipantDetailProvider = .init()

    private var webRTCClient: WebRTCClient?
    var activeMeeting: Box<MeetingCellViewModel?> = .init(nil)

    var meetingCode: Box<String> = .init("")


    init() {
        meetingProvider.delegate = self
        participantDetailProvider.delegate = self
    }

    func createNewCode() {
        meetingProvider.disconnect()
        meetingProvider.create()
    }

    func joinMeet(_ handler: (_ viewModel: MeetingViewModel) -> Void) {
        // WebRTC send sdp
        let iceServers = RTCConfig.default.webRTCIceServers
        webRTCClient = WebRTCClient(iceServers: iceServers)
        webRTCClient?.delegate = self
        webRTCClient?.offer { [weak self] sdp in
            guard let self else { return }

            participantDetailProvider.send(sdp: SessionDescription(from: sdp))
        }

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

    func clearCollection(collection: FSCollection) {
        switch collection {
        case .meetingRoom:
            FSCollectionManager.meetingRoom.clearCollection()
        case .participantDetail:
            FSCollectionManager.participantDetail.clearCollection()
        }
    }

    func readParticipantDetail() {
        participantDetailProvider.read(participantId: Participant.currentUser.id)
    }
}

extension MeetsViewModel: MeetingRoomProviderDelegate {
    func meetingRoom(_ provider: MeetingRoomProvider, newMeetingCode: String) {
        meetingCode.value = newMeetingCode
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveUpdate meetingRoom: MeetingRoom) {
        meetingRoom.participants.forEach { participant in
            participantDetailProvider.read(participantId: participant.id)
        }
    }

    func meetingRoom(_ provider: MeetingRoomProvider, didRecieveError error: Error) {
        print(error)
    }
}

extension MeetsViewModel: WebRTCClientDelegate {
    func webRTCClient(
        _ client: WebRTCClient,
        didDiscoverLocalCandidate candidate: RTCIceCandidate
    ) {
        participantDetailProvider.send(iceCandidate: IceCandidate(from: candidate))
    }

    func webRTCClient(
        _ client: WebRTCClient,
        didChangeConnectionState state: RTCIceConnectionState
    ) {}

    func webRTCClient(
        _ client: WebRTCClient,
        didReceiveData data: Data
    ) {}
}

extension MeetsViewModel: ParticipantDetailProviderDelegate {
    func didReceive(_ provider: ParticipantDetailProvider, participantDetail: ParticipantDetail) {
        guard let sdp = participantDetail.sdp?.rtcSessionDescription else { return }
        webRTCClient?.set(remoteSdp: sdp) { error in
            guard let error else { return }
            print(error)
        }

        participantDetail.iceCandidates
            .map(\.rtcIceCandidate)
            .forEach { rtcIceCandidate in
                webRTCClient?.set(remoteCandidate: rtcIceCandidate) { error in
                    guard let error else { return }
                    print(error)
                }
            }
    }
}
