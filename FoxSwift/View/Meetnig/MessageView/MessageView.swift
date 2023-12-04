//
//  MessageView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

protocol MessageViewDelegate: AnyObject {
    func selectImage(_ messageView: MessageView)
}

class MessageView: UIView {
    var viewModel: MessageViewModel?
    weak var delegate: MessageViewDelegate?

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
        tableView.registReuseCell(for: FSTextMessageCell.self)
        tableView.registReuseCell(for: FSImageMessageCell.self)

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

            guard !messages.isEmpty else { return }

            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.performBatchUpdates {[weak self] in
                guard let self else { return }

                tableView.insertRows(at: [indexPath], with: .automatic)
            } completion: { [weak self] finished in
                guard let self else { return }

                if finished {
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
    }

    func sendImage(image: UIImage) {
        viewModel?.sendImage(image: image)
    }
}

// MARK: - UITableViewDataSource
extension MessageView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.messages.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel?.messages.value[indexPath.row] else {
            fatalError("no such message")
        }

        let cell = switch message.type {
        case .image, .imageUrl:
            tableView.getReuseCell(for: FSImageMessageCell.self, indexPath: indexPath)
        case .text, .speechText:
            tableView.getReuseCell(for: FSTextMessageCell.self, indexPath: indexPath)
        default:
            fatalError("\(message.type) message haven't implemented")
        }
        guard let cell else { fatalError("No Such Cell") }

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
    func attachmentButtonDidTapped(_ input: MessageInputView) {
        delegate?.selectImage(self)
    }

    func sendButtonDidTapped(_ input: MessageInputView, sendText text: String) {
        guard !text.isEmpty else { return }
        viewModel?.sendMessage(text: text)
    }
}
