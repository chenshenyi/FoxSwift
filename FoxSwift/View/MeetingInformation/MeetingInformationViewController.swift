//
//  MeetingInformationViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

class MeetingInformationViewController: FSViewController {
    var backButton = FSButton()
    var titleLabel = UILabel()
    var selectionView = SelectionView()
    var seperatorline = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        setupBackButton()
        setupTitleLabel()
        setupSelectionView()
        setupSeparator()
        setupConstraint()
    }

    // MARK: Setup subviews
    func setupBackButton() {
        backButton.cornerStyle = .rounded
        backButton.backgroundColor = .fsText.withAlphaComponent(0.1)
        backButton.tintColor = .fsText
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)

        backButton.addAction { [weak self] in
            guard let self else { return }

            navigationController?.popViewController(animated: true)
        }
    }

    func setupTitleLabel() {
        titleLabel.text = "Back to Meeting"
        titleLabel.font = .config(weight: .medium, size: 16)
        titleLabel.textColor = .fsText.withAlphaComponent(0.7)
    }

    func setupSelectionView() {
        selectionView.dataSource = self
        selectionView.delegate = self
    }

    func setupSeparator() {
        seperatorline.backgroundColor = .fsPrimary
    }

    func setupConstraint() {
        backButton.addTo(view) { make in
            make.size.equalTo(30)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().inset(12)
        }

        titleLabel.addTo(view) { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(12)
        }

        selectionView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview().inset(30)
            make.height.equalTo(40)
            make.top.equalTo(backButton.snp.bottom).offset(15)
        }

        seperatorline.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(selectionView)
        }

        view.sendSubviewToBack(seperatorline)
    }
}

extension MeetingInformationViewController: SelectionViewDataSource {
    var selections: [String] {
        ["People", "Schedule", "Other"]
    }

    func numberOfSelections(_ selectionView: SelectionView) -> Int {
        selections.count
    }

    func title(_ selectionView: SelectionView, forIndex index: Int) -> String {
        selections[index]
    }

    func textColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        if index == selectionView.selectedIndex {
            return .accent
        } else {
            return .fsText
        }
    }

    func indicatorColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        .accent
    }

    func font(_ selectionView: SelectionView, forIndex index: Int) -> UIFont {
        .config(weight: .regular, size: 14)
    }
}

extension MeetingInformationViewController: SelectionViewDelegate {}
