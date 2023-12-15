//
//  MessageView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

protocol MessageViewDelegate: AnyObject {
    func didClose(_ messageView: MessageView)

    func selectImage(_ messageView: MessageView)
}

class MessageView: UIView {
    var viewModel: MessageViewModel?
    weak var delegate: MessageViewDelegate?

    // MARK: - Subview
    var header = MessageHeaderView()
    var messageTableView = UITableView()
    var speechTableView = UITableView()
    var messageInputView = MessageInputView()

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        backgroundColor = .fsBg

        setupMessageTableView()
        setupSpeechTableView()
        setupMessageInputView()
        setupHeader()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Subview
    private func setupMessageTableView() {
        messageTableView.dataSource = self
        messageTableView.backgroundColor = .fsBg
        messageTableView.separatorStyle = .none

        // Regist cell
        messageTableView.registReuseCell(for: FSTextMessageCell.self)
        messageTableView.registReuseCell(for: FSImageMessageCell.self)

        // Make constraint
        messageTableView.addTo(self) { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().inset(40)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-70)
        }
    }

    private func setupSpeechTableView() {
        speechTableView.dataSource = self
        speechTableView.backgroundColor = .fsBg
        speechTableView.separatorStyle = .none

        // Regist cell
        speechTableView.registReuseCell(for: FSTextMessageCell.self)
        speechTableView.registReuseCell(for: FSImageMessageCell.self)

        // Make constraint
        speechTableView.addTo(self) { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().offset(12)
        }

        speechTableView.isHidden = true
    }

    private func setupMessageInputView() {
        messageInputView.delegate = self
        messageInputView.addTo(self) { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-70)
        }
    }

    private func setupHeader() {
        header.setupCloseButton { [weak self] in
            guard let self else { return }
            delegate?.didClose(self)
        }
        header.addTo(self) { make in
            make.horizontalEdges.top.equalToSuperview()
            make.height.equalTo(40)
        }

        header.delegate = self
    }

    // MARK: - Setup ViewModel
    func setupViewModel(viewModel: MessageViewModel) {
        self.viewModel = viewModel

        // data binding
        viewModel.messages.bind(listener: messageBinder(for: messageTableView))

        viewModel.speechMessages.bind(listener: messageBinder(for: speechTableView))
    }

    private func messageBinder(for tableView: UITableView) -> ([FSMessage]) -> Void {
        return { [weak tableView] messages in
            guard let tableView else { return }

            guard !messages.isEmpty else { return }

            let messagesCount = messages.count

            let indexPath = IndexPath(row: messagesCount - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.scrollToRow(
                at: IndexPath(row: messagesCount - 1, section: 0),
                at: .top,
                animated: true
            )
        }
    }

    func sendImage(image: UIImage) {
        viewModel?.sendImage(image: image)
    }
}

// MARK: - UITableViewDataSource
extension MessageView: UITableViewDataSource {
    func messages(for tableView: UITableView) -> [FSMessage] {
        guard let viewModel else { return [] }

        switch tableView {
        case messageTableView: return viewModel.messages.value
        case speechTableView: return viewModel.speechMessages.value
        default: return []
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages(for: tableView).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = messages(for: tableView)
        let message = messages[indexPath.row]

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

extension MessageView: SelectionViewDelegate, SelectionViewDataSource {
    func title(_ selectionView: SelectionView, forIndex index: Int) -> String {
        switch index {
        case 0:
            return "Message"
        case 1:
            return "Speech"
        default:
            fatalError("Invalid Index")
        }
    }

    func numberOfSelections(_ selectionView: SelectionView) -> Int {
        2
    }

    func selectionDidSelect(_ selectionView: SelectionView, forIndex index: Int) {
        switch index {
        case 0:
            messageTableView.isHidden = false
            messageInputView.isHidden = false
            speechTableView.isHidden = true

        case 1:
            messageTableView.isHidden = true
            messageInputView.isHidden = true
            speechTableView.isHidden = false

        default:
            fatalError("Invalid Index")
        }
    }

    func indicatorColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        .accent
    }

    func textColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        if selectionView.selectedIndex == index {
            return .accent
        } else {
            return .fsText
        }
    }

    func font(_ selectionView: SelectionView, forIndex index: Int) -> UIFont {
        .config(weight: .regular, size: 12)
    }
}
