//
//  ButtonStack.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/12.
//

import SnapKit
import UIKit

protocol FSButtonStackDelegate<ButtonKey>: AnyObject {
    associatedtype ButtonKey: CaseIterable & Hashable

    typealias ButtonStack = FSButtonStack<ButtonKey>

    func buttonDidTapped(_ buttonStack: ButtonStack, for key: ButtonKey)

    func image(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIImage?

    func tintColor(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIColor

    func backgroundColor(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIColor

    func size(_ buttonStack: ButtonStack, for key: ButtonKey) -> CGFloat

    func cornerStyle(_ buttonStack: ButtonStack, for key: ButtonKey) -> FSButton.CornerStyle
}

class FSButtonStack<ButtonKey: CaseIterable & Hashable>: UIStackView {
    weak var delegate: (any FSButtonStackDelegate<ButtonKey>)? {
        didSet {
            reload()
        }
    }

    var buttons: [ButtonKey: FSButton] = [:]

    // MARK: - Init
    init() {
        super.init(frame: .zero)

        distribution = .equalSpacing
        alignment = .center
        axis = .horizontal

        setupButtons()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupButtons() {
        ButtonKey.allCases.forEach { [weak self] key in
            guard let self else { return }

            let button = FSButton()
            buttons[key] = button

            button.addAction { [weak self] in
                guard let self else { return }
                delegate?.buttonDidTapped(self, for: key)
            }

            addArrangedSubview(button)
        }
    }

    func reload() {
        ButtonKey.allCases.forEach(reloadButton)
    }

    func reloadButton(for key: ButtonKey) {
        guard let button = buttons[key], let delegate else { fatalError("Unknown Button Key") }

        button.cornerStyle = delegate.cornerStyle(self, for: key)
        button.setImage(delegate.image(self, for: key), for: .normal)
        button.tintColor = delegate.tintColor(self, for: key)
        button.backgroundColor = delegate.backgroundColor(self, for: key)

        let size = delegate.size(self, for: key)
        button.snp.remakeConstraints { make in
            make.size.equalTo(size)
        }
    }
}
