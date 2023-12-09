//
//  RecordsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

final class RecordsViewController: FSMeetingTableViewController, FSEditableViewController {
    let viewModel: RecordsViewModel = .init()

    override var meetingCodes: [[Box<MeetingRoom.MeetingCode>]] {
        [viewModel.meetingCodes]
    }

    // MARK: - Subviews
    let editButton = UIBarButtonItem(systemItem: .edit)
    let doneButton = UIBarButtonItem(systemItem: .done)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMeetingTableView()
        setupEditable()
    }

    // MARK: Data Binding
    func bindViewModel() {}

    // MARK: - Setup Subviews
    override func setupMeetingTableView() {
        super.setupMeetingTableView()

        meetingTableView.pinTo(view, safeArea: true)
    }

    override func moveCell(
        from oldIndex: IndexPath,
        to newIndex: IndexPath
    ) {
        viewModel.moveRecord(from: oldIndex.row, to: newIndex.row)
        super.moveCell(from: oldIndex, to: newIndex)
    }

    func startEdit() {
        meetingTableView.dragInteractionEnabled = true
    }

    func stopEdit() {
        meetingTableView.dragInteractionEnabled = false
    }
}
