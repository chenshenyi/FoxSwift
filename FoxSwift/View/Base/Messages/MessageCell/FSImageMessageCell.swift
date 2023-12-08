//
//  FSImageMessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/4.
//

import UIKit

final class FSImageMessageCell: FSMessageCell {
    let pictureView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImage()
        bindViewModel()
    }

    private func setupImage() {
        pictureView.contentMode = .scaleAspectFit
        pictureView.addTo(contentView) { make in
            make.horizontalEdges.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.height.equalTo(120)
            make.bottom.equalTo(contentView).inset(12)
        }
    }

    private func bindViewModel() {
        viewModel.image.bind(inQueue: .main) { [weak self] image in
            self?.pictureView.image = image
        }
    }
}
