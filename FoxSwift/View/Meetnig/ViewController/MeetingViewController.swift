//
//  MeetingViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import CoreServices
import PhotosUI
import UIKit
import UniformTypeIdentifiers

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

    let switchCameraButton = FSButton()

    let meetingInformationViewController = {
        let vc = MeetingInformationViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()

    // MARK: - Message View
    var messageView = MessageView()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupVideoControlBar()
        setupSwitchCameraButton()
        setupCollectionView()
        setupMessageView()

        bindingViewModel()
        viewModel?.requestSpeechRecognition()
    }

    private func bindingViewModel() {
        guard let viewModel else { return }
        bindState()

        viewModel.participants.bind { [weak self] _ in
            guard let self else { return }
            videoCollectionView.reloadData()
        }

        viewModel.sharer.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }
            videoCollectionView.reloadData()
        }
    }

    private func bindState() {
        guard let viewModel else { return }

        viewModel.isOnCamera.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }

            videoControlBar.reloadButton(for: .camera)
        }

        viewModel.isOnMic.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }

            videoControlBar.reloadButton(for: .mic)
        }

        viewModel.isMessage.bind(inQueue: .main) { [weak self] isMessage in
            guard let self, let view else { return }
            messageView.isHidden = !isMessage
            switchCameraButton.isHidden = isMessage
            if isMessage {
                switchCameraButton.snp.remakeConstraints { make in
                    make.size.centerX.centerY.equalTo(0)
                }
            } else {
                switchCameraButton.snp.remakeConstraints { make in
                    make.top.equalTo(view.safeAreaLayoutGuide)
                    make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
                    make.size.equalTo(30)
                }
            }
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

    private func setupSwitchCameraButton() {
        switchCameraButton.cornerStyle = .rounded
        switchCameraButton.backgroundColor = .fsText.withAlphaComponent(0.1)
        switchCameraButton.setImage(.init(systemName: "camera.rotate.fill"), for: .normal)
        switchCameraButton.tintColor = .fsText

        switchCameraButton.addTo(view) { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(30)
        }

        switchCameraButton.addAction { [weak self] in
            guard let self else { return }
            viewModel?.switchCamera()
        }
    }

    func setupMessageView() {
        guard let viewModel else { return }
        let messageViewModel = MessageViewModel(meetingCode: viewModel.meetingCode.value)
        messageView.setupViewModel(viewModel: messageViewModel)
        messageView.delegate = self

        let topInset = view.frame.width / 2 + 10
        messageView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view)
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
        phViewController.overrideUserInterfaceStyle = .dark
        present(phViewController, animated: true)
    }

    func selectFile(_ messageView: MessageView) {
        let documentPickerVC = UIDocumentPickerViewController(
            forOpeningContentTypes: UTType.allCases
        )

        documentPickerVC.overrideUserInterfaceStyle = .dark
        documentPickerVC.allowsMultipleSelection = false
        documentPickerVC.delegate = self

        present(documentPickerVC, animated: true, completion: nil)
    }
}

extension MeetingViewController: FSFileMessageCellDelegate {
    func fileWillDownload(_ cell: FSMessageCell) {
        DispatchQueue.main.async { [weak self] in
            self?.startLoadingView(id: cell.description)
        }
    }

    func fileDidDownload(_ cell: FSFileMessageCell, tempFileUrl: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoadingView(id: cell.description)

            let activityVC = UIActivityViewController(
                activityItems: [tempFileUrl],
                applicationActivities: []
            )
            activityVC.overrideUserInterfaceStyle = .dark
            self?.present(activityVC, animated: true)
        }
    }

    func fileDidDownload(_ cell: FSFileMessageCell, error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoadingView(id: cell.description)
            self?.popup(text: "Error", style: .error) {}
        }
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

extension MeetingViewController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }

        #warning("Bad practice to access the viewModel in subview.\nMust Fix It Later.")
        messageView.viewModel?.sendFile(localUrl: url) { [weak self] error in
            guard let self else { return }

            switch error {
            case .fileTooLarge:
                popup(text: "Exceed 5MB", style: .error) {}

            case .invalidFile:
                popup(text: "Invalide File", style: .error) {}

            case .uploadError:
                popup(text: "Upload Error", style: .error) {}

            case .none:
                break
            }
        }
    }
}
