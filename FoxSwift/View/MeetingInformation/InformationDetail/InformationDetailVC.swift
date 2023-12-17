//
//  InformationDetailVC.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/17.
//

import UIKit

protocol InformationDetailViewModelProtocol {
    var meetingName: Box<String> { get }
    var meetingCode: Box<String> { get }
    var meetingUrl: Box<String> { get }

    var sharedString: String { get }

    func rename(name: String?) throws

    func update(meetingInfo: MeetingInfo)
}

final class InformationDetailViewController: FSViewController, MVVMView {
    typealias ViewModel = InformationDetailViewModelProtocol & MVVMViewModel

    // MARK: - Subviews
    let meetingNameTitle = UILabel()
    let meetingNameTextField = FSTextField()
    let editMeetingNameButton = FSButton()

    let meetingCodeTitle = UILabel()
    let meetingCodeLabel = UILabel()
    let copyButton = FSButton()

    let meetingUrlTitle = UILabel()
    let meetingUrlLabel = UILabel()
    let shareButton = FSButton()

    // MARK: ViewModel
    var viewModel: ViewModel?

    func setupViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel

        viewModel.meetingName.bind { [weak self] name in
            self?.meetingNameTextField.text = name
        }

        viewModel.meetingCode.bind { [weak self] code in
            self?.meetingCodeLabel.text = code
        }

        viewModel.meetingUrl.bind { [weak self] url in
            self?.meetingUrlLabel.text = url
        }
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Information"

        setupNameTitle()
        setupNameTextField()

        setupEditButton()

        setupCodeTitle()
        setupCodeLabel()
        setupCopyButton()

        setupUrlTitle()
        setupUrlLabel()
        setupShareButton()

        setupConstraint()
        disableRename()
    }

    // MARK: Setup Subviews
    func setupNameTitle() {
        meetingNameTitle.text = "Meeting Name"
        meetingNameTitle.font = .config(weight: .medium, size: 16)
        meetingNameTitle.textColor = .fsText.withAlphaComponent(0.7)
    }

    func setupNameTextField() {
        meetingNameTextField.placeholder = "Enter Meeting Name"
        meetingNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter Meeting Name",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.fsText.withAlphaComponent(0.7)
            ]
        )
        meetingNameTextField.font = .config(weight: .medium, size: 16)
        meetingNameTextField.textColor = .fsText
        meetingNameTextField.backgroundColor = .fsText.withAlphaComponent(0.1)
        meetingNameTextField.layer.cornerRadius = 8
        meetingNameTextField.setToolBar()
    }

    func setupEditButton() {
        editMeetingNameButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editMeetingNameButton.tintColor = .fsText.withAlphaComponent(0.7)
        editMeetingNameButton.backgroundColor = .fsText.withAlphaComponent(0.1)
        editMeetingNameButton.layer.cornerRadius = 8

        editMeetingNameButton.addAction(handler: editNameButtonAction)
    }

    func setupCodeTitle() {
        meetingCodeTitle.text = "Meeting Code"
        meetingCodeTitle.font = .config(weight: .medium, size: 16)
        meetingCodeTitle.textColor = .fsText.withAlphaComponent(0.7)
    }

    func setupCodeLabel() {
        meetingCodeLabel.font = .config(weight: .medium, size: 16)
        meetingCodeLabel.textColor = .fsText
    }

    func setupCopyButton() {
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.tintColor = .fsText.withAlphaComponent(0.7)
        copyButton.backgroundColor = .fsText.withAlphaComponent(0.1)
        copyButton.layer.cornerRadius = 8

        copyButton.addAction(handler: copyButtonAction)
    }

    func setupUrlTitle() {
        meetingUrlTitle.text = "Meeting URL"
        meetingUrlTitle.font = .config(weight: .medium, size: 16)
        meetingUrlTitle.textColor = .fsText.withAlphaComponent(0.7)
    }

    func setupUrlLabel() {
        meetingUrlLabel.font = .config(weight: .medium, size: 16)
        meetingUrlLabel.numberOfLines = 0
        meetingUrlLabel.textColor = .fsText
    }

    func setupShareButton() {
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .fsText.withAlphaComponent(0.7)
        shareButton.backgroundColor = .fsText.withAlphaComponent(0.1)
        shareButton.layer.cornerRadius = 8

        shareButton.addAction(handler: shareButtonAction)
    }

    // MARK: Setup Constraint
    func setupConstraint() {
        view.addSubview(meetingNameTitle)
        view.addSubview(meetingNameTextField)
        view.addSubview(editMeetingNameButton)
        view.addSubview(meetingCodeTitle)
        view.addSubview(meetingCodeLabel)
        view.addSubview(copyButton)
        view.addSubview(meetingUrlTitle)
        view.addSubview(meetingUrlLabel)
        view.addSubview(shareButton)

        meetingNameTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.left.equalToSuperview().offset(16)
        }

        meetingNameTextField.snp.makeConstraints { make in
            make.top.equalTo(meetingNameTitle.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        editMeetingNameButton.snp.makeConstraints { make in
            make.centerY.equalTo(meetingNameTextField.snp.centerY)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(48)
        }

        meetingCodeTitle.snp.makeConstraints { make in
            make.top.equalTo(meetingNameTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
        }

        meetingCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingCodeTitle.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        copyButton.snp.makeConstraints { make in
            make.centerY.equalTo(meetingCodeLabel.snp.centerY)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(48)
        }

        meetingUrlTitle.snp.makeConstraints { make in
            make.top.equalTo(meetingCodeLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().inset(16)
        }

        meetingUrlLabel.snp.makeConstraints { make in
            make.top.equalTo(meetingUrlTitle.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(72)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(meetingUrlLabel.snp.centerY)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(48)
        }
    }

    // MARK: Button Functions
    func editNameButtonAction() {
        if meetingNameTextField.isEnabled {
            do {
                try viewModel?.rename(name: meetingNameTextField.text)
                disableRename()
            } catch {
                popup(text: "Empty Name", style: .error) { [weak self] in
                    guard let self else { return }
                    meetingNameTextField.text = viewModel?.meetingName.value
                }
            }
        } else {
            enableRename()
        }
    }

    func enableRename() {
        meetingNameTextField.isEnabled = true
        meetingNameTextField.backgroundColor = .fsText.withAlphaComponent(0.2)
        editMeetingNameButton.backgroundColor = .fsText.withAlphaComponent(0.4)
        editMeetingNameButton.tintColor = .fsText
        editMeetingNameButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
    }

    func disableRename() {
        meetingNameTextField.isEnabled = false
        meetingNameTextField.backgroundColor = .fsText.withAlphaComponent(0.1)
        editMeetingNameButton.backgroundColor = .fsText.withAlphaComponent(0.2)
        editMeetingNameButton.tintColor = .fsText.withAlphaComponent(0.7)
        editMeetingNameButton.setImage(UIImage(systemName: "pencil"), for: .normal)
    }

    func copyButtonAction() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = meetingCodeLabel.text
    }

    func shareButtonAction() {
        guard let sharedString = viewModel?.sharedString else { return }
        let activityVC = UIActivityViewController(
            activityItems: [sharedString],
            applicationActivities: nil
        )
        activityVC.overrideUserInterfaceStyle = .dark
        present(activityVC, animated: true, completion: nil)
    }
}
