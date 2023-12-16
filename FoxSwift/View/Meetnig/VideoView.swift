//
//  VideoView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/23.
//

import UIKit

class VideoView: UIView {
    var participant: Participant?

    var nameLabel = UILabel()

    // MARK: - Init
    convenience init(participant: Participant) {
        self.init(frame: .zero)

        self.participant = participant

        setupView()
        setupNameLabel()
    }

    private func setupView() {
        backgroundColor = .fsPrimary
        clipsToBounds = true
        layer.borderColor = UIColor.fsBg.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
    }

    private func setupNameLabel() {
        nameLabel.text = participant?.name
        nameLabel.textColor = .fsText
        nameLabel.font = .config(weight: .regular, size: 12)
        nameLabel.addTo(self) { make in
            make.bottom.leading.equalToSuperview().inset(12)
        }
    }

    func showNameLabel() {
        bringSubviewToFront(nameLabel)
    }
}
