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

    func setupImage() {}
}
