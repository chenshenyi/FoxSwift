//
//  MessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

class FSMessageCell: UITableViewCell {
    var nameLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = .fsBg
        setupNameLabel()
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
    }
}
