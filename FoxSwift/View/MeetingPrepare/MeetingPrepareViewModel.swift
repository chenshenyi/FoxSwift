//
//  MeetingPrepareViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import UIKit

class MeetingPrepareViewModel {
    // MARK: - Binding Value
    var isCameraOn = Box(true)
    var isMicOn = Box(true)

    var meetingCode = Box("")
    var meetingName = Box("")
    var url = Box("")

    var sharedString: String {
        """
        -- FoxSwift Meeting --
        Use following url to attend the meeting:
        \(url.value)
        
        Or directly paste the following meeting code in app:
        \(meetingName.value)
        """
    }

    // MARK: - Provider
    var meetingRoomProvider: MeetingRoomProvider
    var rtcProvider = RTCProvider()

    init(meetingCode: MeetingRoom.MeetingCode) {
        meetingRoomProvider = .init(meetingCode: meetingCode)
        meetingName.value = meetingCode
        self.meetingCode.value = meetingCode

        url.value = UrlRouteManager.shared.createUrlString(
            for: .meeting,
            components: [meetingCode]
        )
    }

    func joinMeet(handler: @escaping (_ viewModel: MeetingViewModel) -> Void) {
        let viewModel = MeetingViewModel(meetingCode: meetingCode.value)
        handler(viewModel)
    }
    
    func startCaptureVideo(view: UIView) {
        rtcProvider.startCaptureVideo()
        rtcProvider.renderVideo(to: view, for: Participant.currentUser.id, mode: .scaleAspectFit)
    }
}
