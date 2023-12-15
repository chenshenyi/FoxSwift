//
//  UserProvider.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import UIKit

class FSUserProvider {
    static let shared = FSUserProvider()

    enum LoginError: Error {
        case passwordIncorrect
        case emailNotFound
    }

    enum SignUpError: Error {
        case emailAlreadyExist
    }

    typealias Handler<T> = (Result<T, Error>) -> Void

    func createNewUser(user: FSUser) {
        FSCollectionManager<FSUser, FSUser.CodingKeys>(collection: .user)
            .createDocument(data: user, documentID: user.id)
    }

    let collectionManager = FSCollectionManager<FSUser, FSUser.CodingKeys>(collection: .user)

    // MARK: - Listener
    typealias UserListener = (FSUser) -> Void
    var currentUserListeners: [UserListener] = []

    func activeListener(currentUser: FSUser) {
        collectionManager.listenToDocument(documentID: currentUser.id) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(user): listenerBroadCast(user: user)
            default: break
            }
        }
    }

    private func listenerBroadCast(user: FSUser) {
        currentUserListeners.forEach { $0(user) }
    }

    func listenToCurrentUser(handler: @escaping UserListener) {
        currentUserListeners.append(handler)
        if let user = FSUser.currentUser {
            handler(user)
        }
    }

    func updateCurrentUser() {
        guard let currentUser = FSUser.currentUser else { return }
        collectionManager.updateDocument(data: currentUser, documentID: currentUser.id)
    }

    // MARK: Login
    func login(
        email: String,
        password: String,
        handler: @escaping ResultHandler<FSUser, LoginError>
    ) {
        collectionManager.readDocument(documentID: email) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(user):
                if user.password != password {
                    handler(.failure(.passwordIncorrect))
                } else {
                    handler(.success(user))
                    listenerBroadCast(user: user)
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
                listenerBroadCast(user: user)
            }
        }
    }
}
