//
//  MessageCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

class FSMessageCellViewModel {
    var authorName: Box<String> = .init("")
    var isMyMessage: Box<Bool> = .init(false)
    var content: Box<String> = .init("")
    var image: Box<UIImage?> = .init(.init(systemName: "photo"))

    let imageManager = StorageManager.imageManager
    let fileManager = StorageManager.fileManager

    var downloadedUrl = ""

    func setup(message: FSMessage) {
        isMyMessage.value = message.author.id == Participant.currentUser.id

        authorName.value = message.author.name

        let data = message.data
        switch message.type {
        case .text, .speechText:
            content.value = String(data: data, encoding: .utf8) ?? "???"
        case .image:
            image.value = UIImage(data: data)
        case .imageUrl:
            guard let urlString = String(data: data, encoding: .utf8),
                urlString != downloadedUrl,
                let url = URL(string: urlString) else { return }
            downloadedUrl = urlString
            fetchImage(url: url)
        default:
            fatalError("Such type message not available.")
        }
    }

    private func fetchImage(url: URL) {
        image.value = .init(systemName: "photo.artframe")?.withTintColor(.fsSecondary)
        imageManager.download(url: url) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(data):
                image.value = UIImage(data: data)
            case let .failure(error):
                print(error.localizedDescription.red)
            }
        }
    }
}
