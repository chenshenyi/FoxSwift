//
//  FSMeetingTableViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

// MARK: FSMeetingTableViewController
/// - Note: You should manually add the `MeetingTableView` into your view as subview
class FSMeetingTableViewController: FSViewController {
    var meetingInfos: [[Box<MeetingInfo>]] { [] }

    var meetingTableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMeetingTableView()
    }

    private func setupMeetingTableView() {
        meetingTableView.dataSource = self
        meetingTableView.delegate = self

        meetingTableView.backgroundColor = .fsBg

        // Regist cell
        meetingTableView.registReuseCell(for: MeetingCell.self)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        meetingTableView.isEditing = editing
    }
}

// MARK: - TableViewDataSource
extension FSMeetingTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        meetingInfos[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getReuseCell(for: MeetingCell.self, indexPath: indexPath) else {
            fatalError("The cell not regist")
        }
        let meetingInfo = meetingInfos[indexPath.section][indexPath.row]
        meetingInfo.bind { meetingInfo in
            cell.viewModel.setMeetingInfo(meetingInfo: meetingInfo)
        }
        cell.delegate = self
        return cell
    }
}


// MARK: - TableViewDelegate
extension FSMeetingTableViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        meetingInfos.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = .fsSecondary
    }
}

extension FSMeetingTableViewController: MeetingCellDelegate {
    func didSave(_ cell: MeetingCell) {
        popup(text: "Saved", style: .checkmark) {}
    }

    func didUnsave(_ cell: MeetingCell) {
        popup(text: "Unsaved", style: .checkmark) {}
    }
}
