//
//  UserProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

class FSUserProvider {
    typealias Handler<T> = (Result<T, Error>) -> Void

    static func createNewUser(user: FSUser) {
        FSCollectionManager<FSUser, FSUser.CodingKeys>(collection: .user)
            .createDocument(data: user, documentID: user.id)
    }

    let collectionManager = FSCollectionManager<FSUser, FSUser.CodingKeys>(collection: .user)

    func updateCurrentUser() {
        guard let currentUser = FSUser.currentUser else { return }
        collectionManager.updateDocument(data: currentUser, documentID: currentUser.id)
    }

    func listenToCurrentUser(handler: @escaping Handler<FSUser>) {
        guard let currentUser = FSUser.currentUser else { return }

        collectionManager.listenToDocument(
            documentID: currentUser.id,
            completion: handler
        )
    }
}
