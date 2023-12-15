//
//  ParticipantViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import Foundation

class ParticipantsViewModel: TableDataSourceViewModel {
    var participants: Box<[Participant]> = Box([], semaphore: 1)

    func numberOfRows(for section: Int) -> Int {
        participants.value.count
    }

    func cellViewModel(for indexPath: IndexPath) -> MVVMViewModel {
        let participant = participants.value[indexPath.row]

        return ParticipantCellViewModel(
            participant: participant,
            isHost: participant == .currentUser
        )
    }
}
