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

    var userProvider = FSUserProvider()

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
    }
}
