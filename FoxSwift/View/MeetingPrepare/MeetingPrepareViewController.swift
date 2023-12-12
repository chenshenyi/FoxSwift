//
//  MeetingPrepareViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import UIKit

final class MeetingPrepareViewController: FSViewController {
    var viewModel: MeetingPrepareViewModel?

    // MARK: - Subviews
    let meetingNameLabel = UILabel()

    let previewVideo = UIView()
    let voiceButton = FSButton()
    let cameraButton = FSButton()

    let separaterView = UIView()

    let descriptionLablel = UILabel()
    let urlLabel = UILabel()

    let joinButton = FSButton()
    let shareButton = FSButton()

    func setupPresentStyle() {
        if let presentVC = presentationController as? UISheetPresentationController {
            presentVC.detents = [.custom { _ in 540 }]
            presentVC.preferredCornerRadius = 30
        }
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNameLabel()
        setupPreviewVideo()
        setupVoiceButton()
        setupCameraButton()

        setupSeparaterView()

        setupDescriptionLabel()
        setupUrlLabel()
        setupJoinButton()
        setupShareButton()

        setupConstraint()
    }

    // MARK: - Bind ViewModel
    func bindViewModel(viewModel: MeetingPrepareViewModel) {
        self.viewModel = viewModel

        meetingNameLabel.bind(viewModel.meetingName)
        urlLabel.bind(viewModel.url)

        viewModel.isCameraOn.bind(inQueue: .main) { [weak self] isCameraOn in
            guard let self else { return }

            if isCameraOn {
                cameraButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
                cameraButton.tintColor = .accent

            } else {
                cameraButton.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
                cameraButton.tintColor = .accent
            }
        }

        viewModel.isMicOn.bind(inQueue: .main) { [weak self] isMicOn in
            guard let self else { return }

            if isMicOn {
                voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
                voiceButton.tintColor = .accent

            } else {
                voiceButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
                voiceButton.tintColor = .accent
            }
        }
    }

    // MARK: - Setup Subviews
    func setupNameLabel() {
        meetingNameLabel.font = .config(weight: .bold, size: 22)
        meetingNameLabel.textColor = .fsText
    }

    func setupPreviewVideo() {
        previewVideo.backgroundColor = .G_7
        previewVideo.layer.cornerRadius = 12
    }

    func setupVoiceButton() {
        voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        voiceButton.tintColor = .accent
    }

    func setupCameraButton() {
        cameraButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        cameraButton.tintColor = .accent
    }

    func setupSeparaterView() {
        separaterView.backgroundColor = .G_7
    }

    func setupDescriptionLabel() {
        descriptionLablel.text = "Meeting Link"
        descriptionLablel.font = .config(weight: .bold, size: 18)
        descriptionLablel.textColor = .fsSecondary
    }

    func setupUrlLabel() {
        urlLabel.font = .config(weight: .bold, size: 14)
        urlLabel.textColor = .fsText
    }

    func setupShareButton() {
        shareButton.setTitle("Share", for: .normal)
        shareButton.setupStyle(style: .filled(color: .fsPrimary, textColor: .fsText))
        shareButton.addAction(handler: shareMeeting)
    }

    func setupJoinButton() {
        joinButton.setTitle("Join", for: .normal)
        joinButton.setupStyle(style: .filled(color: .accent, textColor: .fsBg))
        joinButton.addAction(handler: joinMeeting)
    }

    func setupConstraint() {
        meetingNameLabel.addTo(view) { make in
            make.centerX.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }

        previewVideo.addTo(view) { make in
            make.top.equalTo(meetingNameLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(200)
        }

        voiceButton.addTo(view) { make in
            make.top.equalTo(previewVideo.snp.bottom).offset(10)
            make.trailing.equalTo(view.snp.centerX).offset(-15)
            make.size.equalTo(50)
        }

        cameraButton.addTo(view) { make in
            make.top.equalTo(previewVideo.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.centerX).offset(15)
            make.size.equalTo(50)
        }

        separaterView.addTo(view) { make in
            make.top.equalTo(voiceButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(4)
            make.height.equalTo(1)
        }

        descriptionLablel.addTo(view) { make in
            make.top.equalTo(separaterView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(30)
        }

        urlLabel.addTo(view) { make in
            make.top.equalTo(descriptionLablel.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(30)
        }

        shareButton.addTo(view) { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(30)
            make.trailing.equalTo(view.snp.centerX).offset(-15)
            make.height.equalTo(30)
        }

        joinButton.addTo(view) { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().inset(30)
            make.leading.equalTo(view.snp.centerX).offset(15)
            make.height.equalTo(30)
        }
    }
    
    // MARK: Function
    func shareMeeting() {
        guard let sharedString = viewModel?.sharedString else { return }
        let activityVC = UIActivityViewController(
            activityItems: [sharedString],
            applicationActivities: nil
        )
        present(activityVC, animated: true, completion: nil)
    }

    func joinMeeting() {
        guard let presentingViewController = presentingViewController else { return }

        viewModel?.joinMeet { [weak self] viewModel in
            guard let self else { return }

            let vc = MeetingViewController()
            vc.viewModel = viewModel
            vc.modalPresentationStyle = .fullScreen

            dismiss(animated: false) {
                presentingViewController.present(vc, animated: true)
            }
        }
    }
}
