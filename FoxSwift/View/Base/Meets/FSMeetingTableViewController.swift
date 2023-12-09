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
    var meetingCodes: [[Box<MeetingRoom.MeetingCode>]] { [] }

    var meetingTableView = UITableView()

    func setupMeetingTableView() {
        meetingTableView.dataSource = self
        meetingTableView.delegate = self
        meetingTableView.dragDelegate = self
        meetingTableView.dropDelegate = self

        meetingTableView.backgroundColor = .fsBg

        // Regist cell
        meetingTableView.registReuseCell(for: MeetingCell.self)
    }

    func moveCell(from oldIndex: IndexPath, to newIndex: IndexPath) {
        DispatchQueue.main.async { [weak meetingTableView] in
            guard let meetingTableView else { return }

            meetingTableView.performBatchUpdates {
                meetingTableView.deleteRows(at: [oldIndex], with: .left)
                meetingTableView.insertRows(at: [newIndex], with: .left)
            }
        }
    }
}

// MARK: - TableViewDataSource
extension FSMeetingTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        meetingCodes[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getReuseCell(for: MeetingCell.self, indexPath: indexPath) else {
            fatalError("The cell not regist")
        }
        let meetingCode = meetingCodes[indexPath.section][indexPath.row]
        meetingCode.bind { meetingCode in
            cell.viewModel.setMeetingCode(meetingCode: meetingCode)
        }
        return cell
    }
}


// MARK: - TableViewDelegate
extension FSMeetingTableViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        meetingCodes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = .fsSecondary
    }
}


// MARK: - TableViewDragDelegate
extension FSMeetingTableViewController: UITableViewDragDelegate {
    func tableView(
        _ tableView: UITableView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let indexPathItem = UIDragItem(itemProvider: .init())
        indexPathItem.localObject = indexPath

        return [indexPathItem]
    }
}

// MARK: - TableViewDropDelegate
extension FSMeetingTableViewController: UITableViewDropDelegate {
    func tableView(
        _ tableView: UITableView,
        canHandle session: UIDropSession
    ) -> Bool {
        true
    }

    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UITableViewDropProposal {
        UITableViewDropProposal(operation: .move, intent: .automatic)
    }

    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let oldIndex = coordinator.session.localDragSession?.items.first?
                  .localObject as? IndexPath else { return }

        moveCell(from: oldIndex, to: destinationIndexPath)
    }
}
