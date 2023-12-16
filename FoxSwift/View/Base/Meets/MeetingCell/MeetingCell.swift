//
//  MeetingCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import SnapKit
import UIKit

protocol MeetingCellDelegate: AnyObject {
    func didSave(_ cell: MeetingCell)

    func didUnsave(_ cell: MeetingCell)
}

class MeetingCell: UITableViewCell {
    weak var delegate: MeetingCellDelegate?

    // MARK: - viewModel
    var viewModel: MeetingCellViewModel = .init()

    // MARK: - Subviews
    var iconView = UIImageView()
    var titleLabel = UILabel()
    var timeLabel = UILabel()
    var saveButton = FSButton()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .fsBg
        selectionStyle = .none
        bindViewModel()
        setupIcon()
        setupTitleLabel()
        setupTimeLabel()
        setupSaveButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup ViewModel
    func bindViewModel() {
        titleLabel.bind(viewModel.meetingName)
        timeLabel.bind(viewModel.createdTime) { value in
            guard let value else { return "" }

            return Date(timeIntervalSinceReferenceDate: TimeInterval(value))
                .formatted(.relative(presentation: .named))
        }

        viewModel.isSaved.bind(inQueue: .main) { [weak self] value in
            let image = value ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            self?.saveButton.setImage(image, for: .normal)
        }
    }

    // MARK: - Setup Subviews
    func setupIcon() {
        iconView.image = .foxWithBubble

        contentView.addSubview(iconView)

        iconView.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(50)
        }
    }

    func setupTitleLabel() {
        titleLabel.font = .config(weight: .regular, size: 14)
        titleLabel.textColor = .fsText

        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.top.equalTo(iconView).inset(6)
        }
    }

    func setupTimeLabel() {
        timeLabel.font = .config(weight: .regular, size: 12)
        timeLabel.textColor = .G_3

        contentView.addSubview(timeLabel)

        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(iconView).inset(6)
        }
    }

    func setupSaveButton() {
        saveButton.setImage(UIImage(systemName: "star"), for: .normal)
        saveButton.tintColor = .accent

        saveButton.addTo(contentView) { make in
            make.size.equalTo(50)
            make.centerY.trailing.equalToSuperview().inset(12)
        }

        saveButton.addAction(handler: saveButtonTapped)
    }

    func saveButtonTapped() {
        if viewModel.isSaved.value {
            viewModel.unsave()
            delegate?.didUnsave(self)
        } else {
            viewModel.save()
            delegate?.didSave(self)
        }
    }
}
