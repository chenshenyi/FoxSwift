//
//  JoinMeetViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/12.
//

import UIKit

final class JoinMeetViewController: FSViewController {
    var viewModel = JoinMeetViewModel()

    // MARK: - Subviews
    let descriptionLabel = UILabel()
    let meetingTextField = FSTextField(placeholder: "Meeting Code")
    let joinButton = FSButton()

    // MARK: - Setup Model Present Style
    func setupModelPresentStyle() {
        if let presentVC = presentationController as? UISheetPresentationController {
            presentVC.detents = [.custom { _ in 220 }]
            presentVC.preferredCornerRadius = 30
        }
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDescriptionLabel()
        setupMeetingTextField()
        setupJoinButton()
    }

    // MARK: - Setup Subviews
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

        joinButton.addAction(handler: joinMeet)
    }

    // MARK: - Join Meet
    func joinMeet() {
        let meetingCode = meetingTextField.text ?? ""
        viewModel.joinMeet(meetingCode: meetingCode) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let viewModel):
                let presentingVC = presentingViewController
                dismiss(animated: false) {
                    let vc = MeetingPrepareViewController()
                    vc.setupPresentStyle()
                    vc.bindViewModel(viewModel: viewModel)
                    presentingVC?.present(vc, animated: true)
                }

            case .failure(.meetingNotExist):
                alertError(text: "No such meeting!")
            }
        }
    }
}
