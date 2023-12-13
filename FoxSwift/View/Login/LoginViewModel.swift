//
//  LoginViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/10.
//

import Foundation

final class LoginViewModel {
    enum SignUpError: Error {
        case invalidEmail(rule: EmailRule)
        case invalidPassword(rule: PasswordRule)
        case invalidUserName(rule: UserNameRule)
        case emailExist
        case unknownError
    }

    enum LoginError: Error {
        case invalidEmail(rule: EmailRule)
        case invalidPassword(rule: PasswordRule)
        case emailNotFound
        case passwordIncorrect
        case unknownError
    }

    typealias LoginResult = Result<FSUser, LoginError>
    typealias SignUpResult = Result<FSUser, SignUpError>

    var currentUser: Box<FSUser?> = .init()

    // MARK: Manager
    var userProvider: FSUserProvider {
        .shared
    }
    var keyChainManager = KeyChainManager()

    func signUp(
        email: String,
        password: String,
        userName: String,
        handler: @escaping (SignUpResult) -> Void
    ) {
        if let failedRule = UserNameRule.allCases.first(where: { rule in
            !rule.check(userName)
        }) {
            handler(.failure(.invalidUserName(rule: failedRule)))
            return
        }

        if let failedRule = EmailRule.allCases.first(where: { rule in
            !rule.check(email)
        }) {
            handler(.failure(.invalidEmail(rule: failedRule)))
            return
        }

        if let failedRule = PasswordRule.allCases.first(where: { rule in
            !rule.check((email: email, password: password))
        }) {
            handler(.failure(.invalidPassword(rule: failedRule)))
            return
        }

        let user = FSUser(id: email, name: userName, email: email, password: password)
        userProvider.signUp(user: user) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(user):
                saveUser(user: user)
                handler(.success(user))
            case .failure(.emailAlreadyExist):
                handler(.failure(.emailExist))
            }
        }
    }

    func login(
        email: String,
        password: String,
        handler: @escaping (LoginResult) -> Void
    ) {
        if let failedRule = EmailRule.allCases.first(where: { rule in
            !rule.check(email)
        }) {
            handler(.failure(.invalidEmail(rule: failedRule)))
            return
        }

        if let failedRule = PasswordRule.allCases.first(where: { rule in
            !rule.check((email: email, password: password))
        }) {
            handler(.failure(.invalidPassword(rule: failedRule)))
            return
        }

        userProvider.login(email: email, password: password) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(user):
                saveUser(user: user)
                handler(.success(user))
            case .failure(.emailNotFound):
                handler(.failure(.emailNotFound))
            case .failure(.passwordIncorrect):
                handler(.failure(.passwordIncorrect))
            }
        }
    }

    func saveUser(user: FSUser) {
        FSUser.currentUser = user
        FSUserProvider.shared.activeListener(currentUser: user)
        keyChainManager.storeUser()
    }
}
