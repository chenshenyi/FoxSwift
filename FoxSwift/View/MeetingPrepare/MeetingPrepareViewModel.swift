//
//  MeetingPrepareViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import Foundation

class MeetingPrepareViewModel {
    // MARK: - Binding Value
    var isCameraOn = Box(true)
    var isMicOn = Box(true)

    var meetingName = Box("")
    var url = Box("")
    
    // MARK: - Provider
    var meetingRoomProvider: MeetingRoomProvider

    init(meetingCode: MeetingRoom.MeetingCode) {
        meetingRoomProvider = .init(meetingCode: meetingCode)
        meetingName.value = meetingCode
        url.value = UrlRouteManager.shared.createUrlString(
            for: .meeting,
            components: [meetingCode]
        )
    }
}
