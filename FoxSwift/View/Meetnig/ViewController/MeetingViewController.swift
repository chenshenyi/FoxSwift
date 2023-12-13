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
    let videoControlBar = FSButtonStack<ButtonKey>()

    var videoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )

    // MARK: - Message View
    var messageView = MessageView()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupVideoControlBar()
        setupCollectionView()
        setupMessageView()

        bindingViewModel()
        viewModel?.requestSpeechRecognition()
    }

    private func bindingViewModel() {
        guard let viewModel else { return }

        viewModel.participants.bind { [weak self] _ in
            guard let self else { return }
            videoCollectionView.reloadData()
        }

        viewModel.isOnCamera.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }

            videoControlBar.reloadButton(for: .camera)
        }

        viewModel.isOnMic.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }

            videoControlBar.reloadButton(for: .mic)
        }

        viewModel.isSharingScreen.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }

            videoControlBar.reloadButton(for: .shareScreen)
        }
        
        viewModel.isMessage.bind(inQueue: .main) { [weak messageView] isMessage in
            messageView?.isHidden = !isMessage
        }

        viewModel.layoutMode.bind(inQueue: .main) { [weak self] mode in
            guard let self else { return }
            switch mode {
            case .oneColumn:
                defaultLayout(1)
            case .twoColumn:
                defaultLayout(2)
            case let .topRow(count):
                topRowLayout(count)
            }
        }
    }

    private func setupVideoControlBar() {
        videoControlBar.addTo(view) { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(60)
            make.horizontalEdges.equalTo(view).inset(20)
        }

        videoControlBar.delegate = self
    }

    func setupMessageView() {
        guard let viewModel else { return }
        let messageViewModel = MessageViewModel(meetingCode: viewModel.meetingCode.value)
        messageView.setupViewModel(viewModel: messageViewModel)
        messageView.delegate = self

        let topInset = view.frame.width / 2 + 10
        messageView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(topInset)
        }
        messageView.isHidden = true
    }
}

extension MeetingViewController: MessageViewDelegate {
    func didClose(_ messageView: MessageView) {
        viewModel?.hideMessage()
    }

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
