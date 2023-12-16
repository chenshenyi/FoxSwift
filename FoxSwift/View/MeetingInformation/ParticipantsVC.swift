//
//  ParticipantsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

protocol ParticipantsViewModelProtocol {
    var participants: Box<[Participant]> { get }
}

class ParticipantsViewController: FSViewController, MVVMView {
    typealias ViewModel = MVVMTableDataSourceViewModel & ParticipantsViewModelProtocol

    var viewModel: ViewModel?

    let tableView = UITableView()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Participants"

        setupTableView()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .fsBg
        tableView.rowHeight = 60

        tableView.pinTo(view, safeArea: true)

        tableView.registReuseCell(for: ParticipantCell.self)
    }

    // MARK: Setup ViewModel
    func setupViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
        viewModel.participants.bind(inQueue: .main) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension ParticipantsViewController: UITableViewDataSource {
    func tableViewCell<Cell: MVVMTableCell>(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> Cell {
        guard let cell = tableView.getReuseCell(for: Cell.self, indexPath: indexPath)
        else { fatalError("\(Cell.reuseIdentifier) not regist.") }

        if let cellViewModel = viewModel?.cellViewModel(for: indexPath) as? Cell.ViewModel {
            cell.setupViewModel(viewModel: cellViewModel)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows(for: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ParticipantCell = tableViewCell(tableView, cellForRowAt: indexPath)
        cell.delegate = self
        return cell
    }
}

// MARK: UITableViewDelegate
extension ParticipantsViewController: UITableViewDelegate {}

// MARK: ParticipantCellDelegate
extension ParticipantsViewController: ParticipantCellDelegate {
    func controlButtonDidTapped(_ cell: ParticipantCell) {
        guard let participant = cell.viewModel?.participant else { return }

        let actionSheet = ParticipantActionSheet(participant: participant)

        present(actionSheet, animated: true, completion: nil)
    }
}
