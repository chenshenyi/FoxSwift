//
//  MessageView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

class MessageView: UIView {
    var viewModel: MessageViewModel?

    // MARK: - Subview
    var header = MessageHeaderView()
    var tableView = UITableView()
    var messageInputView = MessageInputView()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        backgroundColor = .fsBg

        setupTableView()
        setupMessageInputView()
        setupHeader()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Subview
    private func setupTableView() {
        tableView.dataSource = self
        tableView.backgroundColor = .fsBg
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .fsText

        // Regist cell
        tableView.registReuseCell(for: MessageCell.self)

        // Make constraint
        tableView.addTo(self) { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().inset(60)
        }
    }

    private func setupMessageInputView() {
        messageInputView.delegate = self
        messageInputView.addTo(self) { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
    }

    private func setupHeader() {
        header.setupCloseButton { [weak self] in
            guard let self else { return }
            isHidden = true
        }
        header.addTo(self) { make in
            make.horizontalEdges.top.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    // MARK: - Setup ViewModel
    func setupViewModel(viewModel: MessageViewModel) {
        self.viewModel = viewModel

        // data binding
        viewModel.messages.bind { [weak self] messages in
            guard let self else { return }

            tableView.reloadData()
            guard !messages.isEmpty else { return }
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension MessageView: UITableViewDataSource {
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

// MARK: - UITableViewDelegate
extension MessageView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - Message Input View Delegate
extension MessageView: MessageInputViewDelegate {
    func sendButtonDidTapped(_ input: MessageInputView, sendText text: String) {
        guard !text.isEmpty else { return }
        viewModel?.sendMessage(text: text)
    }
}
