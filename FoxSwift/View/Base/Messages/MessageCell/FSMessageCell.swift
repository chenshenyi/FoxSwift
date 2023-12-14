//
//  MessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

class FSMessageCell: UITableViewCell {
    var viewModel: FSMessageCellViewModel = .init()

    var userImageView = UIImageView()
    var nameLabel = UILabel()
    var timeLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = .fsBg
        setupUserImage()
        setupNameLabel()
        setupTimeLabel()
        bindViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Subview
    private func setupUserImage() {
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 15

        userImageView.addTo(contentView) { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(8)
            make.size.equalTo(30)
        }
    }

    private func setupNameLabel() {
        nameLabel.textColor = .fsSecondary
        nameLabel.font = .config(weight: .regular, size: 14)
        nameLabel.addTo(contentView) { make in
            make.leading.equalTo(userImageView.snp.trailing).offset(12)
            make.top.equalTo(contentView).inset(12)
        }
    }
    
    private func setupTimeLabel() {
        timeLabel.textColor = .G_3
        timeLabel.font = .config(weight: .regular, size: 10)
        timeLabel.addTo(contentView) { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
            make.firstBaseline.equalTo(nameLabel)
        }
    }

    private func bindViewModel() {
        nameLabel.bind(viewModel.authorName)
        
        timeLabel.bind(viewModel.createdTime)
        
        viewModel.authorImage.bind(inQueue: .main) { [weak self] image in
            self?.userImageView.image = image
        }

        viewModel.isMyMessage.bind(inQueue: .main) { [weak self] isMyMessage in
            self?.nameLabel.textColor = isMyMessage ? .fsSecondary : .fsSecondary
        }
    }
}
