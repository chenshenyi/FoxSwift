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

    init(meetingCode: String) {
        self.meetingCode = .init(meetingCode)
    }

    func fetchRemoteVideo(into view: UIView) {
        let renderer = RTCMTLVideoView(
            frame: view.frame
        )
        renderer.videoContentMode = .scaleAspectFit

        rtcProvider?.renderRemoteVideo(to: renderer)

        renderer.addTo(view) { make in
            make.margins.equalToSuperview()
        }
        view.layoutIfNeeded()
    }

    func fetchLocalVideo(into view: UIView) {
        let renderer = RTCMTLVideoView(
            frame: view.frame
        )
        renderer.videoContentMode = .scaleAspectFit

        rtcProvider?.startCaptureLocalVideo(renderer: renderer)

        renderer.addTo(view) { make in
            make.margins.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
}
