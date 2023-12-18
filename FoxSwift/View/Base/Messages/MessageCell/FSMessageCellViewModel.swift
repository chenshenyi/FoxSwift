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
    var fileName = Box("")
    var fileSize = Box("")
    var fileUrlString = ""

    let imageManager = StorageManager.imageManager
    let storageFileManager = StorageManager.fileManager

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
        case .text, .speechText:
            content.value = String(data: data, encoding: .utf8) ?? "???"

        case .image:
            image.value = UIImage(data: data)

        case .imageUrl:
            guard let urlString = String(data: data, encoding: .utf8),
                  let url = URL(string: urlString) else { return }
            fetchImage(url: url)

        case .fileUrl:
            guard let file = try? JSONDecoder().decode(FSFile.self, from: data) else { return }
            fileName.value = file.name
            fileSize.value = sizeFormattedString(size: file.size)
            fileUrlString = file.urlString

        default:
            fatalError("Such type message not available.")
        }
    }

    private func sizeFormattedString(size: Int) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB, .useKB, .useBytes] // optional: restricts the units to MB only
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(size))
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

    enum DownloadError: Error {
        case downloadError
        case localError
    }

    func fetchFile(handler: @escaping ResultHandler<URL, DownloadError>) {
        guard let url = URL(string: fileUrlString) else {
            handler(.failure(.downloadError))
            return
        }

        storageFileManager.download(url: url) { [weak self] result in
            guard let self else {
                handler(.failure(.localError))
                return
            }

            switch result {
            case let .success(data):
                let tempDirectory = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirectory.appendingPathComponent(fileName.value)

                do {
                    try data.write(to: tempFileURL)
                    handler(.success(tempFileURL))
                } catch {
                    handler(.failure(.localError))
                    return
                }

            case .failure:
                handler(.failure(.downloadError))
            }
        }
    }
}
