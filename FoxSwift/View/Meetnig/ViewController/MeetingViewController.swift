//
//  MeetingViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import PhotosUI
import UIKit

@MainActor
final class MeetingViewController: FSViewController {
    // MARK: - ViewModel
    var viewModel: MeetingViewModel?

    // MARK: - SubViews
    private var recordButton = UIButton()

    let videoControlBar = VideoControlBar()

    var videoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )

    // MARK: - Message View
    var messageView = MessageView()

    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        viewModel?.leaveMeet()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindingViewModel()
        setupCollectionView()
        setupVideoControlBar()
        setupMessageView()
//        viewModel?.requestSpeechRecognition()
    }

    private func bindingViewModel() {
        viewModel?.participants.bind { [weak self] _ in
            guard let self else { return }
            videoCollectionView.reloadData()
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

        videoControlBar.messageButton.onHandler = { [weak self] in
            guard let self else { return }
            messageView.isHidden = false
            layoutWhenMessaging(4)
        }
        videoControlBar.messageButton.offHandler = { [weak self] in
            guard let self else { return }
            messageView.isHidden = true
        }
        videoControlBar.messageButton.isOn = false
    }

    func setupMessageView() {
        guard let viewModel else { return }
        let messageViewModel = MessageViewModel(meetingCode: viewModel.meetingCode.value)
        messageView.setupViewModel(viewModel: messageViewModel)
        messageView.delegate = self

        messageView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().inset(200)
        }
        messageView.isHidden = true
    }
}

extension MeetingViewController: MessageViewDelegate {
    func selectImage(_ messageView: MessageView) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let phViewController = PHPickerViewController(configuration: config)
        phViewController.delegate = self
        present(phViewController, animated: true)
    }
}

extension MeetingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let first = results.first else { return }
        first.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let error {
                print(error)
                return
            }

            guard let image = image as? UIImage else { return }

            self?.messageView.sendImage(image: image)
        }
    }
}
