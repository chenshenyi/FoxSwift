//
//  InformationDetailVM.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/17.
//

import Foundation

class InformationDetailViewModel: MVVMViewModel, InformationDetailViewModelProtocol {
    var meetingName = Box("")

    var meetingCode = Box("")

    var meetingUrl = Box("")

    // MARK: Manager
    var meetingRoomProvider: MeetingRoomProvider?

    var sharedString: String {
        """
        -- FoxSwift Meeting --
        Use following url to attend the meeting:
        \(meetingUrl.value)

        Or directly paste the following meeting code in app:
        \(meetingName.value)
        """
    }

    func update(meetingInfo: MeetingInfo) {
        meetingName.value = meetingInfo.meetingName ?? ""
        meetingCode.value = meetingInfo.meetingCode
        meetingUrl.value = UrlRouteManager.shared.createUrlString(
            for: .meeting,
            components: [meetingCode.value]
        )

        meetingRoomProvider = .init(meetingCode: meetingCode.value)
    }

    enum RenameError: Error {
        case nameCantBeEmpty
    }

    func rename(name: String?) throws {
        guard let name, !name.isEmpty else { throw RenameError.nameCantBeEmpty }

        meetingRoomProvider?.rename(name: name)
        FSUser.currentUser?.meetingHistory.first { meetingInfo in
            meetingInfo.meetingCode == meetingCode.value
        }?.meetingName = name
        FSUser.currentUser?.recentMeets.first {
            $0.meetingCode == meetingCode.value
        }?.meetingName = name
        FSUser.currentUser?.records.first {
            $0.meetingCode == meetingCode.value
        }?.meetingName = name
        FSUserProvider.shared.updateCurrentUser()
    }
}
