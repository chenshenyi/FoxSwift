//
//  RecordsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

final class RecordsViewController: FSMeetingTableViewController {
    let viewModel: RecordsViewModel = .init()

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
extension RecordsViewController {
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        "Records"
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
            viewModel.deleteRecord(for: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        viewModel.moveRecord(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meetingInfo = meetingInfos[indexPath.section][indexPath.row].value
        let viewModel = RecordDetailViewModel(
            meetingCode: meetingInfo.meetingCode,
            name: meetingInfo.meetingName
        )

        let viewController = RecordDetailViewController()
        viewController.setupViewModel(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
