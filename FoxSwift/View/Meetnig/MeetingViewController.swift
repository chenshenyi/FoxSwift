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
    private var recordButton = UIButton()
    private var remoteVideoView = UIView()
    private var localVideoView = UIView()

    let videoControlBar = VideoControlBar()

    var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    
    var messageTableView = UITableView()

    // MARK: - LifeCycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.leaveMeet()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindingViewModel()
        setupMultiuserView()
        setupVideoControlBar()
    }

    private func bindingViewModel() {
        viewModel?.participants.bind { [weak self] _ in
            guard let self else { return }
            collectionView.reloadData()
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

    private func setupVideoControlBar() {
        videoControlBar.addTo(view) { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(view)
        }
        videoControlBar.micButton.onHandler = viewModel?.turnOnMic
        videoControlBar.micButton.offHandler = viewModel?.turnOffMic
        videoControlBar.speakerButton.onHandler = viewModel?.turnOnAudio
        videoControlBar.speakerButton.offHandler = viewModel?.turnOffAudio
        videoControlBar.cameraButton.onHandler = viewModel?.turnOnCamera
        videoControlBar.cameraButton.offHandler = viewModel?.turnOffCamera
    }
}
