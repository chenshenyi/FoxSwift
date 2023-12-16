//
//  MeetingInformationViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/16.
//

import Foundation

class MeetingInformationViewModel: MVVMViewModel, MeetingInformationViewModelProtocol {
    var participantViewModel: ParticipantsViewModelProtocol & MVVMTableDataSourceViewModel

    init() {
        participantViewModel = ParticipantsViewModel()
    }
    
    func update(participants: [Participant]) {
        participantViewModel.participants.value = participants
    }
}
