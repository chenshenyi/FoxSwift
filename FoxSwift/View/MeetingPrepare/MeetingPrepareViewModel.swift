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
    var meetingInfo: MeetingInfo?
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

    var userProvider: FSUserProvider {
        .shared
    }

    init(meetingInfo: MeetingInfo) {
        let meetingCode = meetingInfo.meetingCode
        self.meetingInfo = meetingInfo
        meetingRoomProvider = .init(meetingCode: meetingCode)
        meetingName.value = meetingInfo.meetingName ?? meetingCode
        self.meetingCode.value = meetingCode

        url.value = UrlRouteManager.shared.createUrlString(
            for: .meeting,
            components: [meetingCode]
        )

        FSUser.currentUser?.addRecent(meetingInfo: meetingInfo)
        userProvider.updateCurrentUser()
    }

    func joinMeet(handler: @escaping (_ viewModel: MeetingViewModel) -> Void) {
        guard let meetingInfo else { return }
        let viewModel = MeetingViewModel(meetingInfo: meetingInfo)
        handler(viewModel)
    }

    func addToHistory() {
        guard let meetingInfo else { return }
        FSUser.currentUser?.addHistory(meetingInfo: meetingInfo)
        userProvider.updateCurrentUser()
    }

    func startCaptureVideo(view: UIView) {
        rtcProvider.startCaptureVideo()
        rtcProvider.renderVideo(to: view, for: Participant.currentUser.id, mode: .scaleAspectFit)
    }
}
