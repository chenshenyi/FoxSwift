//
//  MessageInputView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/26.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func sendButtonDidTapped(_ input: MessageInputView, sendText text: String)
}

class MessageInputView: UIView {
    let textView = UITextView()
    let doneButton = UIButton()

    weak var delegate: MessageInputViewDelegate?

    // MARK: - Init
    init() {
        super.init(frame: .zero)

        setupDoneButton()
        setupTextView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupSubview
    func setupTextView() {
        textView.backgroundColor = .fsBg
        textView.textColor = .fsText
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.fsSecondary.cgColor

        textView.setToolBar()

        textView.addTo(self) { make in
            make.verticalEdges.leading.equalToSuperview().inset(6)
            make.trailing.equalTo(doneButton.snp.leading).offset(-6)
        }
    }

    func setupDoneButton() {
        doneButton.setImage(.init(systemName: "paperplane.fill"), for: .normal)
        doneButton.tintColor = .fsSecondary

        doneButton.addTo(self) { make in
            make.centerY.trailing.equalToSuperview().inset(6)
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
