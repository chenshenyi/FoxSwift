//
//  JoinMeetViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/12.
//

import UIKit

final class JoinMeetViewController: FSViewController {
    // MARK: Subviews
    let descriptionLabel = UILabel()
    let meetingTextField = FSTextField(placeholder: "Meeting Code")
    let joinButton = FSButton()

    // MARK: Setup Model Present Style
    func setupModelPresentStyle() {
        if let presentVC = presentationController as? UISheetPresentationController {
            presentVC.detents = [.custom { _ in 220 }]
            presentVC.preferredCornerRadius = 30
        }
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDescriptionLabel()
        setupMeetingTextField()
        setupJoinButton()
    }

    // MARK: Setup Subviews
    func setupDescriptionLabel() {
        descriptionLabel.text = "Enter the meeting code shared by the meeting organizer."
        descriptionLabel.font = .config(weight: .regular, size: 16)
        descriptionLabel.textColor = .fsText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.addTo(view) { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    func setupMeetingTextField() {
        meetingTextField.backgroundColor = .fsPrimary
        meetingTextField.textColor = .fsText
        meetingTextField.setToolBar()
        meetingTextField.addTo(view) { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
    }

    func setupJoinButton() {
        joinButton.cornerStyle = .rounded
        joinButton.setupStyle(style: .filled(color: .accent, textColor: .fsPrimary))
        joinButton.setTitle("Join", for: .normal)
        joinButton.titleLabel?.font = .config(weight: .regular, size: 14)
        joinButton.addTo(view) { make in
            make.top.equalTo(meetingTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
    }
}
