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
    let tableView = UITableView()
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
        bindingViewModel()
        #if DEBUG
            setupDeubgTool()
        #endif
    }

    // MARK: - Setup Subviews
    func bindingViewModel() {
        viewModel.meetingCode.bind { [weak self] meetingCode in
            guard let self else { return }

            textField.text = meetingCode
        }
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .fsSecondary.withAlphaComponent(0.5)

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

        joinMeetingButton.addAction { [weak self] in
            guard let self else { return }

            if let text = textField.text, !text.isEmpty {
                viewModel.meetingCode.value = text
            }

            viewModel.joinMeet { [weak self] viewModel in
                guard let self else { return }

                let vc = MeetingViewController()
                vc.viewModel = viewModel

                navigationController?.pushViewController(vc, animated: true)
            }
        }

        view.addSubview(joinMeetingButton)
        joinMeetingButton.snp.makeConstraints { make in
            make.leading.equalTo(newMeetingButton.snp.trailing).offset(16)
            make.width.equalTo(newMeetingButton.snp.width)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(76)
        }
    }
}


// MARK: - TableViewDataSource
extension MeetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getReuseCell(for: MeetingCell.self, indexPath: indexPath) else {
            fatalError("The cell not regist")
        }

        switch indexPath.row {
        case 0:
            viewModel.activeMeeting.bind { viewModel in
                guard let viewModel else { return }
                cell.setupViewModel(viewModel: viewModel)
            }
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Activate"
    }
}


// MARK: - TableViewDelegate
extension MeetsViewController: UITableViewDelegate {}
