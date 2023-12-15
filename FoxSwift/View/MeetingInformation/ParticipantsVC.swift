//
//  ParticipantsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

class ParticipantsViewController: UIViewController, MVVMView {
    typealias ViewModel = TableDataSourceViewModel

    var viewModel: ViewModel?

    let tableView = UITableView()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.pinTo(view, safeArea: true)

        tableView.registReuseCell(for: ParticipantCell.self)
    }

    // MARK: Setup ViewModel
    func setupViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

extension ParticipantsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows(for: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ParticipantCell = tableViewCell(tableView, cellForRowAt: indexPath)
        return cell
    }
}

extension ParticipantsViewController: UITableViewDelegate {}
