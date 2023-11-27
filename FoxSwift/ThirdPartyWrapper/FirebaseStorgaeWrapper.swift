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

    let reference: StorageReference

    init(folder: StorageFolder) {
        reference = Self.db.child(folder.rawValue)
    }
}
