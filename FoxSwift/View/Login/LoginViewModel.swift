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
        case inavlidPassword(rule: PasswordRule)
        case emailNotFound
        case passwordIncorrect
        case unknownError
    }

    typealias UserId = FSUser.UserId

    var currentUser: Box<FSUser?> = .init()

    var userProvider = FSUserProvider()

    func signUp(
        email: String,
        password: String,
        userName: String,
        handler: @escaping ResultHandler<UserId, SignUpError>
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

        if let failedRule = UserNameRule.allCases.first(where: { rule in
            !rule.check(userName)
        }) {
            handler(.failure(.invalidUserName(rule: failedRule)))
            return
        }
    }

    func login(
        email: String,
        password: String,
        handler: @escaping ResultHandler<UserId, LoginError>
    ) {
        let name = "小熊貓 \(Int(Date().timeIntervalSince1970))"
        let user = FSUser(id: UUID().uuidString, name: name)
        FSUser.currentUser = user
        FSUserProvider.createNewUser(user: user)
    }
}
