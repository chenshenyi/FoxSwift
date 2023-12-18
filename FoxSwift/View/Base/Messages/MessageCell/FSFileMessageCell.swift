//
//  FSFileMessageCell.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/18.
//

import UIKit

protocol FSFileMessageCellDelegate: AnyObject {
    func fileWillDownload(_ cell: FSMessageCell)
    func fileDidDownload(_ cell: FSFileMessageCell, error: Error)
    func fileDidDownload(_ cell: FSFileMessageCell, tempFileUrl: URL)
}

final class FSFileMessageCell: FSMessageCell {
    typealias ViewModel = FSMessageCellViewModel

    weak var delegate: (any FSFileMessageCellDelegate)?

    var fileBackground = UIView()
    var fileNameLabel = UILabel()
    var fileSizeLabel = UILabel()
    var downloadButton = FSButton()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupFileBackground()
        setupFileNameLabel()
        setupFileSizeLabel()
        setupDownloadButton()

        setupContstraint()
        setupViewModel(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Subview
    private func setupFileBackground() {
        fileBackground.backgroundColor = .fsText.withAlphaComponent(0.1)
        fileBackground.layer.cornerRadius = 12
        fileBackground.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
    }

    private func setupFileNameLabel() {
        fileNameLabel.textColor = .fsSecondary
        fileNameLabel.font = .config(weight: .regular, size: 14)
        fileNameLabel.numberOfLines = 0
    }

    private func setupFileSizeLabel() {
        fileSizeLabel.textColor = .fsText.withAlphaComponent(0.5)
        fileSizeLabel.font = .config(weight: .regular, size: 10)
    }

    private func setupDownloadButton() {
        downloadButton.setImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
        downloadButton.tintColor = .fsSecondary

        downloadButton.addAction { [weak self] in
            guard let self else { return }

            delegate?.fileWillDownload(self)
            viewModel.fetchFile { [weak self] result in
                guard let self else { return }

                switch result {
                case let .success(url):
                    delegate?.fileDidDownload(self, tempFileUrl: url)

                case let .failure(error):
                    delegate?.fileDidDownload(self, error: error)
                }
            }
        }
    }

    private func setupContstraint() {
        fileBackground.addTo(contentView) { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.leading.equalTo(nameLabel)
            make.bottom.trailing.equalToSuperview().inset(12)
        }

        fileNameLabel.addTo(fileBackground) { make in
            make.top.leading.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(40)
        }

        fileSizeLabel.addTo(fileBackground) { make in
            make.leading.bottom.equalToSuperview().inset(12)
            make.top.equalTo(fileNameLabel.snp.bottom).offset(12)
        }

        downloadButton.addTo(fileBackground) { make in
            make.trailing.centerY.equalToSuperview().inset(12)
            make.size.equalTo(40)
        }
    }

    func setupViewModel(viewModel: ViewModel) {
        fileNameLabel.bind(viewModel.fileName)
        fileSizeLabel.bind(viewModel.fileSize)
    }
}
