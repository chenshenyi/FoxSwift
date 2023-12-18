//
//  MessageTableView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/8.
//

import UIKit

class FSMessageViewController: FSViewController {
    var messages: [FSMessage] { [] }

    var messageTableView = UITableView()

    func setupMessageTableView() {
        messageTableView.dataSource = self
        messageTableView.delegate = self

        messageTableView.dataSource = self
        messageTableView.backgroundColor = .fsBg
        messageTableView.separatorStyle = .none

        // Regist cell
        messageTableView.registReuseCell(for: FSTextMessageCell.self)
        messageTableView.registReuseCell(for: FSImageMessageCell.self)
        messageTableView.registReuseCell(for: FSFileMessageCell.self)
    }
}

// MARK: UITableViewDataSource
extension FSMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        let cell = switch message.type {
        case .image, .imageUrl:
            tableView.getReuseCell(for: FSImageMessageCell.self, indexPath: indexPath)

        case .text, .speechText:
            tableView.getReuseCell(for: FSTextMessageCell.self, indexPath: indexPath)

        case .fileUrl:
            tableView.getReuseCell(for: FSFileMessageCell.self, indexPath: indexPath)

        default:
            fatalError("\(message.type) message haven't implemented")
        }
        guard let cell else { fatalError("No Such Cell") }

        cell.viewModel.setup(message: message)
        if let cell = cell as? FSFileMessageCell {
            cell.delegate = self
        }

        return cell
    }
}

// MARK: UITableViewDelegate
extension FSMessageViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension FSMessageViewController: FSFileMessageCellDelegate {
    func fileWillDownload(_ cell: FSMessageCell) {
        DispatchQueue.main.async { [weak self] in
            self?.startLoadingView(id: cell.description)
        }
    }

    func fileDidDownload(_ cell: FSFileMessageCell, tempFileUrl: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoadingView(id: cell.description)

            let activityVC = UIActivityViewController(
                activityItems: [tempFileUrl],
                applicationActivities: []
            )
            activityVC.overrideUserInterfaceStyle = .dark
            self?.present(activityVC, animated: true)
        }
    }

    func fileDidDownload(_ cell: FSFileMessageCell, error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoadingView(id: cell.description)
            self?.popup(text: "Error", style: .error) {}
        }
    }
}
