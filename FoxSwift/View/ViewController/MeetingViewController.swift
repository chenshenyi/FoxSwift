//
//  MeetingViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import UIKit


final class MeetingViewController: FSViewController {
    // MARK: - ViewModel
    var viewModel: MeetingViewModel?

    // MARK: - SubViews
    private var remoteVideoView = UIView()
    private var recordButton = UIButton()

    private var localVideoView = UIView()

    // MARK: - LifeCycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.leaveMeet()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecordButton()
    }

    private func bindingViewModel() {
        viewModel?.participants.bind { [weak self] participants in
            guard let self, let remoteParticipant = participants.first(where: { participant in
                participant.id != Participant.currentUser.id
            })
            else {
                return
            }
            viewModel?.fetchRemoteVideo(into: remoteVideoView, for: remoteParticipant)
        }
    }

    // MARK: - Setup Subviews
    private func setupRemoteVideoView() {
        remoteVideoView.backgroundColor = .G_7

        remoteVideoView.addTo(view) { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(remoteVideoView.snp.width).multipliedBy(9.0 / 16.0)
        }
    }

    private func setupLocalVideoView() {
        localVideoView.backgroundColor = .G_9

        localVideoView.addTo(view) { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(160)
            make.width.equalTo(90)
        }
    }

    private func setupRecordButton() {
        recordButton.setImage(.init(systemName: "video.circle.fill"), for: .normal)
        recordButton.contentVerticalAlignment = .fill
        recordButton.contentHorizontalAlignment = .fill

        recordButton.addTo(view) { make in
            make.width.height.equalTo(50)
            make.centerY.trailing.equalToSuperview().inset(16)
        }

        recordButton.addAction { [weak self] in
            guard let self else { return }

            viewModel?.fetchLocalVideo(into: localVideoView)
        }
    }

    private func setupMultiuserView() {}
}
