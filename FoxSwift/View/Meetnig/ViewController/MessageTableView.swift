//
//  messageTableView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

extension MeetingViewController {
    func setupMessageTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self

        messageTableView.backgroundColor = .fsBg
        messageTableView.layer.borderColor = UIColor.fsSecondary.cgColor
        messageTableView.layer.borderWidth = 1

        messageTableView.registReuseCell(for: MessageCell.self)

        viewModel?.messages.bind { [weak self] messages in
            guard let self else { return }

            messageTableView.reloadData()
            guard !messages.isEmpty else { return }
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }

        messageTableView.addTo(view) { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().inset(200)
        }

        messageInputView.delegate = self
        messageInputView.addTo(view) { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
    }
}

extension MeetingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.messages.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getReuseCell(for: MessageCell.self, indexPath: indexPath) else {
            fatalError("Message cell not regist.")
        }
        guard let message = viewModel?.messages.value[indexPath.row] else {
            fatalError("no such message")
        }

        cell.viewModel.setup(message: message)

        return cell
    }
}

extension MeetingViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }
}


extension MeetingViewController: MessageInputViewDelegate {
    func sendButtonDidTapped(_ input: MessageInputView, sendText text: String) {
        guard !text.isEmpty else { return }
        viewModel?.sendMessage(text: text)
    }
}
