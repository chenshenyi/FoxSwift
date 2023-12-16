//
//  MeetingInformationViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

protocol MeetingInformationViewModelProtocol {
    var participantViewModel: ParticipantsViewModelProtocol & MVVMTableDataSourceViewModel { get }
}

final class MeetingInformationViewController: FSViewController, MVVMView {
    typealias ViewModel = MVVMViewModel & MeetingInformationViewModelProtocol

    var viewModel: ViewModel?

    // MARK: - Subviews
    let backButton = FSButton()
    let titleLabel = UILabel()
    let selectionView = SelectionView()
    let seperatorline = UIView()

    // MARK: - Children
    let participantsViewController = ParticipantsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        setupBackButton()
        setupTitleLabel()
        setupSeparator()
        setupConstraint()

        setupChildren()
        setupSelectionView()
    }

    // MARK: Setup subviews
    func setupBackButton() {
        backButton.cornerStyle = .rounded
        backButton.backgroundColor = .fsText.withAlphaComponent(0.1)
        backButton.tintColor = .fsText
        backButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)

        backButton.addAction { [weak self] in
            guard let self else { return }

            dismiss(animated: true)
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
        selectionView.selectedIndex = 0
    }

    func setupSeparator() {
        seperatorline.backgroundColor = .fsText.withAlphaComponent(0.3)
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

    // MARK: Setup Children
    func setupChildren() {
        [participantsViewController, UIViewController(), UIViewController()].forEach { child in
            addChild(child)
            child.view.addTo(view) { make in
                make.horizontalEdges.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalTo(seperatorline.snp.bottom)
            }
            child.didMove(toParent: self)
            child.view.isHidden = true
            child.view.backgroundColor = .fsBg
        }
    }

    func setupViewModel(viewModel: ViewModel) {
        participantsViewController.setupViewModel(viewModel: viewModel.participantViewModel)
    }
}

// MARK: SelectionViewDataSource
extension MeetingInformationViewController: SelectionViewDataSource {
    func numberOfSelections(_ selectionView: SelectionView) -> Int {
        children.count
    }

    func title(_ selectionView: SelectionView, forIndex index: Int) -> String {
        children[index].title ?? "Tab\(index)"
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

// MARK: SelectionViewDelegate
extension MeetingInformationViewController: SelectionViewDelegate {
    func selectionDidSelect(_ selectionView: SelectionView, forIndex index: Int) {
        children.forEach { vc in
            vc.view.isHidden = true
        }
        children[index].view.isHidden = false
    }
}
