//
//  MessageCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import UIKit

class FSMessageCellViewModel {
    var authorName = Box("")
    var authorImage: Box<UIImage?> = .init(.fox)
    var createdTime = Box("")
    var isMyMessage = Box(false)
    var content = Box("")
    var image: Box<UIImage?> = .init(.placeholder)

    let imageManager = StorageManager.imageManager
    let fileManager = StorageManager.fileManager

    func setup(message: FSMessage) {
        isMyMessage.value = message.author.id == Participant.currentUser.id

        authorName.value = message.author.name

        if let smallPictureData = message.author.smallPicture {
            authorImage.value = UIImage(data: smallPictureData)
        }

        createdTime.value = Date(timeIntervalSince1970: TimeInterval(message.createdTime))
            .formatted(.dateTime)

        let data = message.data
        switch message.type {
        case .text, .speechText, .fileUrl:
            content.value = String(data: data, encoding: .utf8) ?? "???"

        case .image:
            image.value = UIImage(data: data)

        case .imageUrl:
            guard let urlString = String(data: data, encoding: .utf8),
                  let url = URL(string: urlString) else { return }
            fetchImage(url: url)

        default:
            fatalError("Such type message not available.")
        }
    }

    private func fetchImage(url: URL) {
        image.value = .placeholder
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
