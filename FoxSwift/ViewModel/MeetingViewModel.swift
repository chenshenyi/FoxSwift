//
//  MeetingViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import WebRTC

class MeetingViewModel {
    var meetingCode: Box<String>
    var participants: Box<[Participant]> = .init([])

    var rtcProvider: RTCProvider?
    var meetingProvider: MeetingRoomProvider?

    init(meetingCode: String) {
        self.meetingCode = .init(meetingCode)
    }

    func fetchRemoteVideo(into view: UIView, for participant: Participant) {
        rtcProvider?.renderVideo(to: view, for: participant.id)
        view.layoutIfNeeded()
    }

    func fetchLocalVideo(into view: UIView) {
        rtcProvider?.startCaptureVideo()
        rtcProvider?.renderVideo(to: view, for: Participant.currentUser.id)
        view.layoutIfNeeded()
    }

    func leaveMeet() {
        meetingProvider?.disconnect()
    }
}
