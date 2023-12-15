//
//  SelectionView.swift
//  DV1
//
//  Created by chen shen yi on 2023/10/30.
//

import UIKit


/// A horizontal control that consists of selections, each selection functioning as a discrete button.
class SelectionView: UIStackView {
    // MARK: - Delegate and DataSource

    weak var delegate: SelectionViewDelegate?

    var dataSource: SelectionViewDataSource? {
        didSet {
            reloadData()
        }
    }

    // MARK: - Subview

    private(set) var selections: [UIButton] = []

    var selectedIndex: Int = 0 {
        didSet {
            guard let dataSource else { return }

            // if selectedIndex is invalid, set to the oldValue
            guard selectedIndex >= 0,
                  selectedIndex < dataSource.numberOfSelections(self),
                  delegate?.selectionShouldSelect(self, forIndex: oldValue) != false
            else {
                selectedIndex = oldValue
                return
            }

            moveIndicator()
            updateButtonView()
            delegate?.selectionDidSelect(self, forIndex: selectedIndex)
        }
    }

    private var indicator = UIView()

    // MARK: Init
    init() {
        super.init(frame: .zero)

        distribution = .fillEqually
        alignment = .fill
        addSubview(indicator)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update Data
    func reloadData() {
        guard let dataSource else { return }

        let oldNumber = selections.count
        let newNumber = dataSource.numberOfSelections(self)

        if oldNumber != newNumber {
            // setup views and constraints
            selections = (0 ..< newNumber).map { _ in UIButton() }
            selections.forEach { button in
                addArrangedSubview(button)
            }
        }

        // Button Action
        selections.enumerated().forEach { index, button in
            button.tag = index

            button.addAction { [weak self] _ in
                self?.selectedIndex = index
            }
        }
        selectedIndex = 0
    }

    private func updateButtonView() {
        guard let dataSource else { return }

        selections.enumerated().forEach { index, button in
            let title = dataSource.title(self, forIndex: index)
            let font = dataSource.font(self, forIndex: index)
            let textColor = dataSource.textColor(self, forIndex: index)

            button.tag = index
            button.titleLabel?.font = font
            button.setTitle(title, for: .normal)
            button.setTitleColor(textColor, for: .normal)
        }
    }

    private func moveIndicator() {
        if selections.isEmpty {
            indicator.isHidden = true
            return
        }

        indicator.isHidden = false
        layoutIfNeeded()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            indicator.snp.remakeConstraints { [weak self] make in
                guard let self else { return }

                make.height.equalTo(1)
                make.bottom.width.centerX.equalTo(selections[selectedIndex])
            }
            indicator.backgroundColor = dataSource?.indicatorColor(self, forIndex: selectedIndex)
            layoutIfNeeded()
        }
    }
}
