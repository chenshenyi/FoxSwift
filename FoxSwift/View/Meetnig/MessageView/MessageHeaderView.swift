//
//  MessageHeaderView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

class MessageHeaderView: UIView {
    let titleLabel = UILabel()
    let closeButton = UIButton()

    // MARK: Init
    init() {
        super.init(frame: .zero)

        backgroundColor = .fsPrimary
        layer.borderWidth = 1
        layer.borderColor = UIColor.fsBg.cgColor
        setupCloseButton()
        setupTitleLabel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup Subview
    private func setupTitleLabel() {
        titleLabel.textColor = .accent
        titleLabel.text = "Messages"

        titleLabel.addTo(self) { make in
            make.centerY.leading.equalToSuperview().inset(12)
        }
    }

    private func setupCloseButton() {
        closeButton.setImage(.init(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .accent

        closeButton.addTo(self) { make in
            make.size.equalTo(30)
            make.centerY.trailing.equalToSuperview().inset(12)
        }
    }

    func setupCloseButton(handler: @escaping () -> Void) {
        closeButton.addAction(handler: handler)
    }
}
