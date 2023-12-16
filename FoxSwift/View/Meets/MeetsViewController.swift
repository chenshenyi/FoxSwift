//
//  MeetsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/16.
//

import SnapKit
import UIKit

final class MeetsViewController: FSMeetingTableViewController {
    // MARK: - Subviews
    let joinMeetingButton = FSButton()
    let newMeetingButton = FSButton()

    // MARK: - ViewModel
    let viewModel = MeetsViewModel()

    override var meetingInfos: [[Box<MeetingInfo>]] {
        [viewModel.meets.value]
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        bindingViewModel()

        setupNewMeetingButton()
        setupJoinMeetingButton()
        setupTableView()
    }

    // MARK: - Setup Subviews
    func bindingViewModel() {
        viewModel.listenToUser()
        viewModel.meets.bind(inQueue: .main) { [weak self] _ in
            self?.meetingTableView.reloadData()
        }
    }

    func setupTableView() {
        meetingTableView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(newMeetingButton.snp.bottom).offset(24)
        }
    }

    func setupNewMeetingButton() {
        newMeetingButton.setTitle("New Meeting", for: .normal)
        newMeetingButton.titleLabel?.font = .config(weight: .medium, size: 14)
        newMeetingButton.cornerStyle = .rounded
        newMeetingButton.setupStyle(style: .filled(color: .fsPrimary, textColor: .fsText))

        newMeetingButton.addAction(handler: newMeeting)

        newMeetingButton.addTo(view) { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalTo(view.snp.centerX).offset(-8)
            make.height.equalTo(40)
        }
    }

    func setupJoinMeetingButton() {
        joinMeetingButton.setTitle("Join Meeting", for: .normal)
        joinMeetingButton.titleLabel?.font = .config(weight: .medium, size: 14)
        joinMeetingButton.cornerStyle = .rounded
        joinMeetingButton.setupStyle(style: .filled(color: .fsSecondary, textColor: .fsBg))

        joinMeetingButton.addAction(handler: joinMeet)

        joinMeetingButton.addTo(view) { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.trailing.equalToSuperview().inset(15)
            make.leading.equalTo(view.snp.centerX).offset(8)
            make.height.equalTo(40)
        }
    }

    private func newMeeting() {
        viewModel.createNewCode(showPrepare)
    }

    private func joinMeet() {
        let vc = JoinMeetViewController()
        vc.setupModelPresentStyle()
        present(vc, animated: true)
    }
}


// MARK: - TableViewDataSource
extension MeetsViewController {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Meeting"
    }
}

// MARK: - TableViewDelegate
extension MeetsViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meetingInfo = meetingInfos[indexPath.section][indexPath.row].value
        viewModel.joinMeet(meetingInfo: meetingInfo, handler: showPrepare)
    }
}
