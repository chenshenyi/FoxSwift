//
//  RecordsViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import UIKit

final class HistoryViewController: FSMeetingTableViewController {
    let viewModel: HistoryViewModel = .init()

    override var meetingInfos: [[Box<MeetingInfo>]] { [viewModel.meetingInfos.value] }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMeetingTableView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLoadingView(id: "Loading")
        viewModel.loadData { [weak self] in
            self?.stopLoadingView(id: "Loading")
        }
    }

    // MARK: Data Binding
    func bindViewModel() {
        viewModel.meetingInfos.bind(inQueue: .main) { [weak self] _ in
            self?.meetingTableView.reloadData()
        }
    }

    // MARK: - Setup Subviews
    func setupMeetingTableView() {
        meetingTableView.addTo(view) { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: TableViewDelegate
extension HistoryViewController {
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        "History Meeting"
    }

    // MARK: - Edit
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            viewModel.deleteHistory(for: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPrepare(viewModel: viewModel.prepareViewModel(for: indexPath))
    }
}
