//
//  messageTableView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

extension MeetingViewController {
    func setupmessageTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.registReuseCell(for: MessageCell.self)

        viewModel?.messages.bind { [weak self] _ in
            self?.messageTableView.reloadData()
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
            fatalError("")
        }
        
        cell.viewModel.setup(message: message)
        
         return cell
    }
}

extension MeetingViewController: UITableViewDelegate {}
