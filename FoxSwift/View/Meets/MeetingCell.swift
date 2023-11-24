//
//  MeetingCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import SnapKit
import UIKit

class MeetingCell: UITableViewCell {
    // MARK: - viewModel
    var viewModel: MeetingCellViewModel?

    // MARK: - Subviews
    var iconView = UIImageView()
    var titleLabel = UILabel()
    var timeLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup ViewModel
    func setupViewModel(viewModel: MeetingCellViewModel) {
        self.viewModel = viewModel

        titleLabel.bind(viewModel.meetingName)
        timeLabel.bind(viewModel.createdTime) { value in
            Date(timeIntervalSinceNow: TimeInterval(value))
                .formatted(.relative(presentation: .named))
        }
    }

    // MARK: - Setup Subviews
    func setupIcon() {
        iconView.image = .foxWithBubble

        contentView.addSubview(iconView)

        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(70)
        }
    }

    func setupTitleLabel() {
        titleLabel.font = .config(weight: .regular, size: 18)
        titleLabel.textColor = .fsText

        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.top.equalTo(iconView).offset(12)
        }
    }

    func setupTimeLabel() {
        timeLabel.font = .config(weight: .regular, size: 16)
        timeLabel.textColor = .G_3

        contentView.addSubview(timeLabel)

        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
    }
}
