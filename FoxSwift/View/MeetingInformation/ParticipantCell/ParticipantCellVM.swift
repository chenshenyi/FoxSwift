//
//  ParticipantCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

class ParticipantCellViewModel: ParticipantCellViewModelProtocol, MVVMViewModel {
    var name: String {
        participant.name
    }

    var image: UIImage {
        guard let data = participant.smallPicture,
              let image = UIImage(data: data)
        else { return .defaultSmallProfilePicture }

        return image
    }

    var participant: Participant

    init(participant: Participant, isHost: Bool) {
        self.participant = participant
    }
}
