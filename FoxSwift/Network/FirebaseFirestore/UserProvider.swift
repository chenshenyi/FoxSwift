//
//  UserProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

class FSUserProvider {
    enum LoginError: Error {
        case passwordIncorrect
        case emailNotFound
    }

    enum SignUpError: Error {
        case emailAlreadyExist
    }

    typealias Handler<T> = (Result<T, Error>) -> Void

    static func createNewUser(user: FSUser) {
        FSCollectionManager<FSUser, FSUser.CodingKeys>(collection: .user)
            .createDocument(data: user, documentID: user.id)
    }

    let collectionManager = FSCollectionManager<FSUser, FSUser.CodingKeys>(collection: .user)

    func login(
        email: String,
        password: String,
        handler: @escaping ResultHandler<FSUser, LoginError>
    ) {
        collectionManager.readDocument(documentID: email) { result in
            switch result {
            case let .success(user):
                if user.password != password {
                    handler(.failure(.passwordIncorrect))
                } else {
                    handler(.success(user))
                }
            case .failure:
                handler(.failure(.emailNotFound))
            }
        }
    }

    func signUp(
        user: FSUser,
        handler: @escaping ResultHandler<FSUser, SignUpError>
    ) {
        collectionManager.readDocument(documentID: user.email) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                handler(.failure(.emailAlreadyExist))
            case .failure:
                collectionManager.createDocument(data: user, documentID: user.email)
                handler(.success(user))
            }
        }
    }

    func updateCurrentUser() {
        guard let currentUser = FSUser.currentUser else { return }
        collectionManager.updateDocument(data: currentUser, documentID: currentUser.id) { result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription.red)
            case .success:
                break
            }
        }
    }

    func listenToCurrentUser(handler: @escaping Handler<FSUser>) {
        guard let currentUser = FSUser.currentUser else { return }

        collectionManager.listenToDocument(
            documentID: currentUser.id,
            completion: handler
        )
    }
}
