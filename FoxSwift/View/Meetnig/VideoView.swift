//
//  VideoView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/23.
//

import UIKit

class VideoView: UIView {
    var participant: Participant?

    convenience init(participant: Participant) {
        self.init(frame: .zero)

        self.participant = participant
        backgroundColor = .fsPrimary
        clipsToBounds = true
        layer.borderColor = UIColor.fsBg.cgColor
        layer.borderWidth = 1
    }
}
