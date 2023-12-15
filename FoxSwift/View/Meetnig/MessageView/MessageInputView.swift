//
//  MessageInputView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/26.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func attachmentButtonDidTapped(_ input: MessageInputView)
    func sendButtonDidTapped(_ input: MessageInputView, sendText text: String)
}

class MessageInputView: UIView {
    let attachmentButton = UIButton()
    let textView = UITextView()
    let doneButton = UIButton()

    weak var delegate: MessageInputViewDelegate?

    // MARK: - Init
    init() {
        super.init(frame: .zero)

        backgroundColor = .fsPrimary

        setupAttachmentButton()
        setupDoneButton()
        setupTextView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupSubview
    func setupAttachmentButton() {
        attachmentButton.setImage(.init(systemName: "paperclip"), for: .normal)
        attachmentButton.tintColor = .fsSecondary

        attachmentButton.addTo(self) { make in
            make.top.leading.equalToSuperview().inset(8)
            make.size.equalTo(30)
        }

        attachmentButton.addAction { [weak self] in
            guard let self else { return }

            textView.endEditing(true)
            delegate?.attachmentButtonDidTapped(self)
        }
    }

    func setupTextView() {
        textView.backgroundColor = .fsBg
        textView.textColor = .fsText
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.layer.cornerRadius = 14
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.fsSecondary.cgColor

        textView.setToolBar()

        textView.addTo(self) { make in
            make.top.equalToSuperview().inset(8)
            make.centerY.equalTo(doneButton)
            make.leading.equalTo(attachmentButton.snp.trailing).offset(6)
            make.trailing.equalTo(doneButton.snp.leading).offset(-6)
        }
    }

    func setupDoneButton() {
        doneButton.setImage(.init(systemName: "paperplane.fill"), for: .normal)
        doneButton.tintColor = .fsText

        doneButton.addTo(self) { make in
            make.trailing.top.equalToSuperview().inset(8)
            make.size.equalTo(30)
        }

        doneButton.addAction { [weak self] in
            guard let self else { return }

            textView.endEditing(true)
            delegate?.sendButtonDidTapped(self, sendText: textView.text)
            textView.text = ""
        }
    }
}
