//
//  FSImageMessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/4.
//

import UIKit

final class FSImageMessageCell: FSMessageCell {
    let image = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImage()
    }

    func setupImage() {
        imageView?.contentMode = .scaleAspectFill
        imageView?.addTo(contentView) { make in
            make.horizontalEdges.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom)
            make.bottom.equalTo(contentView)
            make.height.equalTo(100)
        }
    }
}
