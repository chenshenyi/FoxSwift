//
//  MeetsViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/16.
//

import SnapKit
import UIKit

final class MeetsViewController: FSViewController {
    // MARK: - Subviews
    let textField = UITextField()
    let shareButton = UIButton()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let joinMeetingButton = UIButton()
    let newMeetingButton = UIButton()


    // MARK: - ViewModel
    let viewModel = MeetsViewModel()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupTableView()
        setupNewMeetingButton()
        setupJoinMeetingButton()
        setupShareButton()
        bindingViewModel()
    }

    // MARK: - Setup Subviews
    func bindingViewModel() {
        viewModel.meetingCode.bind { [weak self] meetingCode in
            guard let self else { return }

            textField.text = meetingCode
        }

        viewModel.meets.bind { [weak self] _ in
            guard let self else { return }

            tableView.reloadData()
        }

        viewModel.listenToUser()
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .fsBg

        tableView.registReuseCell(for: MeetingCell.self)

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(138)
        }
    }

    func setupTextField() {
        textField.backgroundColor = .fsPrimary
        textField.textColor = .fsText
        textField.placeholder = "MeetingCode"
        textField.setToolBar()

        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin).offset(20)
            make.height.equalTo(30)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    func setupNewMeetingButton() {
        newMeetingButton.setTitle("New Meeting", for: .normal)
        newMeetingButton.setTitleColor(.accent, for: .normal)
        newMeetingButton.titleLabel?.font = .config(weight: .regular, size: 14)

        newMeetingButton.backgroundColor = .clear

        newMeetingButton.layer.borderColor = UIColor.accent.cgColor
        newMeetingButton.layer.borderWidth = 1
        newMeetingButton.layer.cornerRadius = 4

        newMeetingButton.addAction { [weak self] in
            guard let self else { return }

            viewModel.createNewCode()
        }

        view.addSubview(newMeetingButton)
        newMeetingButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(76)
        }
    }

    func setupJoinMeetingButton() {
        joinMeetingButton.setTitle("Join Meeting", for: .normal)
        joinMeetingButton.setTitleColor(.fsSecondary, for: .normal)
        joinMeetingButton.titleLabel?.font = .config(weight: .regular, size: 14)

        joinMeetingButton.backgroundColor = .clear

        joinMeetingButton.layer.borderColor = UIColor.fsSecondary.cgColor
        joinMeetingButton.layer.borderWidth = 1
        joinMeetingButton.layer.cornerRadius = 4

        joinMeetingButton.addAction(handler: joinMeet)

        view.addSubview(joinMeetingButton)
        joinMeetingButton.snp.makeConstraints { make in
            make.leading.equalTo(newMeetingButton.snp.trailing).offset(16)
            make.width.equalTo(newMeetingButton.snp.width)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(76)
        }
    }

    private func joinMeet() {
        if let meetingCode = textField.text, !meetingCode.isEmpty {
            joinMeet(meetingCode: meetingCode)
        }
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

    private func setupShareButton() {
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .normal)
        shareButton.tintColor = .accent

        shareButton.addTo(view) { make in
            make.centerY.trailing.equalTo(textField).inset(5)
            make.size.equalTo(30)
        }

        shareButton.addAction(handler: shareMeeting)
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
extension MeetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0
            ? viewModel.activeMeeting.value == nil ? 0 : 1
            : viewModel.meets.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getReuseCell(for: MeetingCell.self, indexPath: indexPath) else {
            fatalError("The cell not regist")
        }

        switch indexPath.section {
        case 0:
            viewModel.activeMeeting.bind { meetingCode in
                guard let meetingCode else { return }
                cell.viewModel.setMeetingCode(meetingCode: meetingCode)
            }
        default:
            let meetingCode = viewModel.meets.value[indexPath.row]
            cell.viewModel.setMeetingCode(meetingCode: meetingCode)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Active" : "History"
    }
}


// MARK: - TableViewDelegate
extension MeetsViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: return
        default:
            viewModel.meetingCode.value = viewModel.meets.value[indexPath.row]
        }
    }
}
