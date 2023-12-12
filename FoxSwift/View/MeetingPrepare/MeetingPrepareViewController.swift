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
        meetingNameLabel.addTo(view) { make in
            make.centerX.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }

    func setupPreviewVideo() {
        previewVideo.backgroundColor = .G_7
        previewVideo.layer.cornerRadius = 12
        previewVideo.addTo(view) { make in
            make.top.equalTo(meetingNameLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(200)
        }
    }

    func setupVoiceButton() {
        voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        voiceButton.tintColor = .accent
        voiceButton.addTo(view) { make in
            make.top.equalTo(previewVideo.snp.bottom).offset(10)
            make.trailing.equalTo(view.snp.centerX).offset(-15)
            make.size.equalTo(50)
        }
    }

    func setupCameraButton() {
        cameraButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        cameraButton.tintColor = .accent
        cameraButton.addTo(view) { make in
            make.top.equalTo(previewVideo.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.centerX).offset(15)
            make.size.equalTo(50)
        }
    }

    func setupSeparaterView() {
        separaterView.backgroundColor = .G_7
        separaterView.addTo(view) { make in
            make.top.equalTo(voiceButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(4)
            make.height.equalTo(1)
        }
    }

    func setupDescriptionLabel() {
        descriptionLablel.text = "Meeting Link"
        descriptionLablel.font = .config(weight: .bold, size: 18)
        descriptionLablel.textColor = .fsSecondary
        descriptionLablel.addTo(view) { make in
            make.top.equalTo(separaterView.snp.bottom).offset(24)
            make.leading.equalToSuperview().inset(70)
        }
    }

    func setupUrlLabel() {
        urlLabel.font = .config(weight: .bold, size: 14)
        urlLabel.textColor = .fsText
        urlLabel.addTo(view) { make in
            make.top.equalTo(descriptionLablel.snp.bottom)
            make.leading.equalToSuperview().inset(70)
        }
    }

    func setupShareButton() {
        shareButton.setTitle("Share", for: .normal)
        shareButton.setupStyle(style: .filled(color: .fsPrimary, textColor: .fsText))
        shareButton.addTo(view) { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(70)
            make.trailing.equalTo(view.snp.centerX).offset(-15)
            make.height.equalTo(40)
        }
    }

    func setupJoinButton() {
        joinButton.setTitle("Join", for: .normal)
        joinButton.setupStyle(style: .filled(color: .accent, textColor: .fsBg))
        joinButton.addTo(view) { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().inset(70)
            make.leading.equalTo(view.snp.centerX).offset(15)
            make.height.equalTo(40)
        }
    }
}
