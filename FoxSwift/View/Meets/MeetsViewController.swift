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

    override var meetingCodes: [[Box<MeetingRoom.MeetingCode>]] {
        [viewModel.meets.value.map { Box($0) }]
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

    func showPrepare(meetingCode: MeetingRoom.MeetingCode) {
        let vc = MeetingPrepareViewController()

        if let presentVC = vc.presentationController as? UISheetPresentationController {
            presentVC.detents = [.custom { _ in 540 }]
            presentVC.preferredCornerRadius = 30
        }
        present(vc, animated: true)
    }

    private func joinMeet() {
        let vc = JoinMeetViewController()
        vc.setupModelPresentStyle()
        present(vc, animated: true)
    }

    func joinMeet(meetingCode: String) {
        viewModel.meetingCode.value = meetingCode
        viewModel.joinMeet { [weak self] viewModel in
            guard let self else { return }

            let vc = MeetingViewController()
            vc.viewModel = viewModel

            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func shareMeeting() {
        let meetingCode = viewModel.meetingCode.value

        guard !meetingCode.isEmpty else { return }

        let urlString = UrlRouteManager.shared.createUrlString(
            for: .meeting,
            components: [meetingCode]
        )

        let sharedString = """
        -- FoxSwift Meeting --
        Use following url to attend the meeting:
        \(urlString)

        Or directly paste the following meeting code in app:
        \(meetingCode)
        """

        let activityVC = UIActivityViewController(
            activityItems: [sharedString],
            applicationActivities: nil
        )
        present(activityVC, animated: true, completion: nil)
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
        let meetingCode = meetingCodes[indexPath.section][indexPath.row].value
        showPrepare(meetingCode: meetingCode)
    }
}
