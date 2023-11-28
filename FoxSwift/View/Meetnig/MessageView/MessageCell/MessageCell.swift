//
//  MessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

class MessageCell: UITableViewCell {
    var viewModel = MessageCellViewModel()

    var nameLabel = UILabel()
    var contentTextView = UITextView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = .fsBg
        setupNameLabel()
        setupContentTextView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Subview
    private func setupNameLabel() {
        nameLabel.textColor = .fsSecondary
        nameLabel.addTo(contentView) { make in
            make.horizontalEdges.equalTo(contentView).inset(16)
            make.top.equalTo(contentView).inset(12)
        }

        nameLabel.bind(viewModel.author) { [weak self] author in
            guard let self else { return "" }

            if author.id == Participant.currentUser.id {
                nameLabel.textColor = .accent
                return "You"
            } else {
                nameLabel.textColor = .fsSecondary
                return author.name
            }
        }
    }

    private func setupContentTextView() {
        contentTextView.font = .config(weight: .regular, size: 14)
        contentTextView.textColor = .fsText
        contentTextView.backgroundColor = .fsBg
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false

        contentTextView.addTo(contentView) { make in
            make.horizontalEdges.equalTo(contentView).inset(12)
            make.top.equalTo(nameLabel.snp.bottom)
            make.bottom.equalTo(contentView)
        }

        viewModel.content.bind { [weak self] content in
            self?.contentTextView.text = content
        }
    }
}
