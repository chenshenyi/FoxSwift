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

    override var messages: [FSMessage] {
        viewModel?.messages.value ?? []
    }

    var viewModel: (any ViewModel)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMessageTableView()
    }

    override func setupMessageTableView() {
        super.setupMessageTableView()
        messageTableView.pinTo(view, safeArea: true)
    }

    func setupViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
        bindViewModel()
    }

    func bindViewModel() {
        viewModel?.messages.bind(inQueue: .main) { [weak self] _ in
            guard let self else { return }
            messageTableView.reloadData()
        }
    }
}
