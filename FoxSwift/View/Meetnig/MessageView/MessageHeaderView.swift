//
//  MessageHeaderView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

class MessageHeaderView: UIView {
    let closeButton = UIButton()
    let selectionView = SelectionView()
    
    weak var delegate: (SelectionViewDelegate&SelectionViewDataSource)? {
        didSet {
            selectionView.dataSource = delegate
            selectionView.delegate = delegate
        }
    }

    // MARK: Init
    init() {
        super.init(frame: .zero)

        backgroundColor = .fsPrimary
        layer.borderWidth = 1
        layer.borderColor = UIColor.fsBg.cgColor
        setupCloseButton()
        setupSelectionView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup Subview
    private func setupCloseButton() {
        closeButton.setImage(.init(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .accent

        closeButton.addTo(self) { make in
            make.size.equalTo(30)
            make.centerY.trailing.equalToSuperview().inset(14)
        }
    }

    private func setupSelectionView() {
        selectionView.addTo(self) { make in
            make.top.equalToSuperview().inset(1)
            make.bottom.equalToSuperview().inset(1)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
    }

    func setupCloseButton(handler: @escaping () -> Void) {
        closeButton.addAction(handler: handler)
    }
}
