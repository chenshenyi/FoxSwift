//
//  FirebaseStorgaeWrapper.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/26.
//

import FirebaseStorage

enum StorageFolder: String {
    case image = "Image"
    case file = "File"
}

enum DefaultImage: String {
    case profileImage = "Default/Profile-Image"
    case banner = "Default/Banner"
    case smallProfileImage = "Default/Small-Profile-Image"

    var imageData: Data? {
        let image = switch self {
        case .profileImage:
            UIImage.defaultProfilePicture

        case .smallProfileImage:
            UIImage.defaultSmallProfilePicture

        case .banner:
            UIImage.defaultBanner
        }

        return image.pngData()
    }
}

class StorageManager {
    static let db = Storage.storage().reference()
    static let fileManager = StorageManager(folder: .file)
    static let imageManager = StorageManager(folder: .image)

    let reference: StorageReference

    private var cache: [String: Data] = [:]
    private var cacheQueue: [String] = []
    private var cacheCounter: Double = 0
    private var cacheLimit = 2e20

    init(folder: StorageFolder) {
        reference = Self.db.child(folder.rawValue)
    }

    func upload(data: Data, name: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = reference.child(name)
        reference.putData(data, metadata: nil) { _, error in
            if let error {
                completion(.failure(error))
            } else {
                reference.downloadURL { url, error in
                    if let error {
                        completion(.failure(error))
                    } else if let url {
                        completion(.success(url))
                    }
                }
            }
        }
    }

    func download(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        if let data = DefaultImage(rawValue: url.absoluteString)?.imageData {
            completion(.success(data))
            return
        }

        if let data = cache[url.absoluteString] {
            completion(.success(data))
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }

            if let error {
                completion(.failure(error))
            } else if let data {
                cache[url.absoluteString] = data
                cacheQueue.append(url.absoluteString)
                cacheCounter += Double(data.count)
                reduceCache()
                completion(.success(data))
            }
        }
        .resume()
    }

    private func reduceCache() {
        if cacheCounter > cacheLimit {
            let removedKey = cacheQueue.removeFirst()
            if let removedData = cache.removeValue(forKey: removedKey) {
                cacheCounter -= Double(removedData.count)
            }
            reduceCache()
        }
    }

    func clearCache() {
        cache.removeAll()
        cacheCounter = 0
    }
}
