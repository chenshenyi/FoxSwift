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
        
        setupNameLabel()
        setupContentTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Subview
    private func setupNameLabel() {
        nameLabel.textColor = .fsPrimary
        nameLabel.addTo(contentView) { make in
            make.horizontalEdges.top.equalTo(contentView).inset(12)
        }
    }
    
    private func setupContentTextView() {
        contentTextView.textColor = .fsText
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        
        contentTextView.addTo(contentView) { make in
            make.horizontalEdges.bottom.equalTo(contentView).inset(12)
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
        }
    }
    
    // MARK: - Setup Data
    func setupData(author: String, content: String) {
        nameLabel.text = author
        contentTextView.text = content
    }
}
