//
//  FSTextMessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/4.
//

import UIKit

final class FSTextMessageCell: FSMessageCell {
    var contentTextView = UITextView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupContentTextView()
        bindViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Subview
    private func setupContentTextView() {
        contentTextView.font = .config(weight: .regular, size: 14)
        contentTextView.textColor = .fsText
        contentTextView.backgroundColor = .fsBg
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false

        contentTextView.addTo(contentView) { make in
            make.leading.equalTo(nameLabel).offset(-6)
            make.trailing.equalToSuperview().inset(18)
            make.top.equalTo(nameLabel.snp.bottom)
            make.bottom.equalTo(contentView)
        }
    }

    private func bindViewModel() {
        viewModel.content.bind { [weak self] content in
            self?.contentTextView.text = content
        }
    }
}
