//
//  RecordsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

final class RecordsViewController: FSMeetingTableViewController {
    let viewModel: RecordsViewModel = .init()

    override var meetingCodes: [[Box<MeetingRoom.MeetingCode>]] { [viewModel.meetingCodes] }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        setupMeetingTableView()
    }

    // MARK: Data Binding
    func bindViewModel() {}

    // MARK: - Setup Subviews
    func setupMeetingTableView() {
        meetingTableView.addTo(view) { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: TableViewDelegate
extension RecordsViewController {
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
        let meetingCode = meetingCodes[indexPath.section][indexPath.row].value
        let viewModel = RecordDetailViewModel(meetingCode: meetingCode)

        let viewController = RecordDetailViewController()
        viewController.setupViewModel(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
