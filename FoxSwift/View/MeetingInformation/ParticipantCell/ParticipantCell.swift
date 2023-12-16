//
//  ParticipantCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

protocol ParticipantCellViewModelProtocol: MVVMViewModel {
    var name: String { get }

    var image: UIImage { get }

    var participant: Participant { get }
}

protocol ParticipantCellDelegate: AnyObject {
    func controlButtonDidTapped(_ cell: ParticipantCell)
}

class ParticipantCell: UITableViewCell, MVVMTableCell {
    typealias ViewModel = ParticipantCellViewModelProtocol

    var viewModel: ViewModel?

    weak var delegate: ParticipantCellDelegate?

    // MARK: Subview
    let nameLabel = UILabel()
    let picture = UIImageView()
    let controlButton = FSButton()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        setupNameLabel()
        setupPicture()
        setupControlButton()
        setupConstraint()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup Subview
    func setupNameLabel() {
        nameLabel.font = .config(weight: .regular, size: 12)
        nameLabel.textColor = .fsText
    }

    func setupPicture() {
        picture.contentMode = .scaleAspectFill
        picture.clipsToBounds = true
        picture.layer.cornerRadius = 20
    }

    func setupControlButton() {
        controlButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        controlButton.tintColor = .fsText
        controlButton.backgroundColor = .G_9.withAlphaComponent(0.1)
        controlButton.cornerStyle = .rounded

        controlButton.addAction(handler: controlButtonDidTapped)
    }

    func controlButtonDidTapped() {
        delegate?.controlButtonDidTapped(self)
    }

    func setupConstraint() {
        picture.addTo(contentView) { make in
            make.size.equalTo(40)
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        nameLabel.addTo(contentView) { make in
            make.leading.equalTo(picture.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }

        controlButton.addTo(contentView) { make in
            make.size.equalTo(30)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Setup ViewModel
    func setupViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel

        nameLabel.text = viewModel.name

        picture.image = viewModel.image
    }
}
