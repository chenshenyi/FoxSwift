//
//  ParticipantActionSheet.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/16.
//

import UIKit

class ParticipantActionSheet: UIAlertController {
    var participant: Participant?
    var imageView = UIImageView()
    let nameLabel = UILabel()

    convenience init(participant: Participant) {
        self.init(
            title: nil,
            message: "\n\n",
            preferredStyle: .actionSheet
        )

        self.participant = participant

        overrideUserInterfaceStyle = .dark

        if let data = participant.smallPicture,
           let image = UIImage(data: data) {
            imageView.image = image
            setupImageView()
            setupNameLabel()
        } else {
            message = participant.name
        }

        setupAcitons()
    }

    func setupImageView() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.addTo(view) { make in
            make.size.equalTo(50)
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(20)
        }
    }

    func setupNameLabel() {
        nameLabel.text = participant?.name
        nameLabel.font = .config(weight: .medium, size: 20)
        nameLabel.textColor = .accent
        nameLabel.addTo(view) { make in
            make.centerY.equalTo(imageView)
            make.centerX.equalToSuperview()
        }
    }

    func setupAcitons() {
        // Add actions to the action sheet
        let report = UIAlertAction(title: "Report", style: .destructive) { _ in }

        let kickOff = UIAlertAction(title: "Kick off", style: .destructive) { _ in }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        if participant != nil {
            addAction(report)
            addAction(kickOff)
        }

        addAction(cancel)
    }
}
