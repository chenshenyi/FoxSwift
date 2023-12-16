//
//  RecordDetailViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

// MARK: RecordsViewModelProtocol
protocol RecordDetailViewModelProtocol {
    var recordName: Box<String> { get }

    var messages: Box<[FSMessage]> { get }

    func renameRecord(name: String)

    func editMessage(newText: String, messageId: FSMessage.ID)
}

// MARK: RecordsViewController
final class RecordDetailViewController: FSMessageViewController {
    typealias ViewModel = RecordDetailViewModelProtocol

    let titleView = FSTextField()

    override var messages: [FSMessage] {
        viewModel?.messages.value ?? []
    }

    var viewModel: (any ViewModel)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setEditing(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMessageTableView()
        setupNavBar()
    }

    override func setupMessageTableView() {
        super.setupMessageTableView()
        messageTableView.addTo(view) { make in
            make.edges.equalToSuperview()
        }
    }

    func setupViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
        bindViewModel()
    }

    func setupNavBar() {
        titleView.textColor = .accent
        titleView.isEnabled = false
        titleView.setToolBar()
        titleView.cornerStyle = .roundSquared(5)
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = editButtonItem
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        titleView.isEnabled = editing
        if editing {
            titleView.backgroundColor = .fsBg
            titleView.textColor = .fsText
        } else {
            titleView.backgroundColor = .clear
            titleView.textColor = .accent
            if let title = titleView.text {
                viewModel?.renameRecord(name: title)
            }
        }
    }

    func bindViewModel() {
        viewModel?.recordName.bind(inQueue: .main) { [weak self] title in
            self?.titleView.text = title
        }
        viewModel?.messages.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }
            messageTableView.reloadData()
        }
    }
}
