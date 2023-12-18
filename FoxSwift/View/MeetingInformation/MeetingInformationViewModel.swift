//
//  MeetingInformationViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/16.
//

import Foundation

class MeetingInformationViewModel: MVVMViewModel, MeetingInformationViewModelProtocol {
    var participantViewModel: ParticipantsViewModelProtocol & MVVMTableDataSourceViewModel
    var informationDetailViewModel: InformationDetailViewModelProtocol & MVVMViewModel
    var whiteboardViewModel: WhiteboardViewModel

    init() {
        participantViewModel = ParticipantsViewModel()
        informationDetailViewModel = InformationDetailViewModel()
        whiteboardViewModel = WhiteboardViewModel()
    }

    func update(participants: [Participant]) {
        participantViewModel.participants.value = participants
    }

    func update(meetingInfo: MeetingInfo) {
        informationDetailViewModel.update(meetingInfo: meetingInfo)
        whiteboardViewModel.update(meetingCode: meetingInfo.meetingCode)
    }
}
