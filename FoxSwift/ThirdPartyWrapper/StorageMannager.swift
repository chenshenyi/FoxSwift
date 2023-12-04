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

class StorageManager {
    static let db = Storage.storage().reference()
    static let fileManager = StorageManager(folder: .file)
    static let imageManager = StorageManager(folder: .image)

    let reference: StorageReference

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
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                completion(.success(data))
            }
        }
        .resume()
    }
}
