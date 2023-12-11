//
//  LoginViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/10.
//

import Foundation

private protocol Rule: Localizable {
    associatedtype Parameters

    var check: (Parameters) -> Bool { get }
}

enum EmailRule: Rule {
    case notEmpty

    var localizedDescription: String {
        "Email should not be empty."
    }

    typealias Email = String

    var check: (Email) -> Bool {
        { email in !email.isEmpty }
    }
}

enum PasswordRule: Rule {
    case notEmpty
    case notSameToEmail

    typealias Email = String
    typealias Password = String
    typealias Parameters = (email: Email, password: Password)

    var localizedDescription: String {
        switch self {
        case .notEmpty: "Password should not be empty."
        case .notSameToEmail: "Password should not be same as email."
        }
    }

    var check: (Parameters) -> Bool {
        switch self {
        case .notEmpty: { arg in !arg.password.isEmpty }
        case .notSameToEmail: { arg in arg.email != arg.password }
        }
    }
}

enum UserNameRule: Rule {
    case notEmpty

    typealias UserName = String

    var localizedDescription: String {
        "User name should not be empty."
    }

    var check: (UserName) -> Bool {
        { userName in !userName.isEmpty }
    }
}

final class LoginViewModel {
    enum SignUpError: Error {
        case invalidEmail(rule: EmailRule)
        case invalidPassword(rule: PasswordRule)
        case invalidUserName(rule: UserNameRule)
        case emailExist
    }

    enum LoginError: Error {
        case invalidEmail(rule: EmailRule)
        case inavlidPassword(rule: PasswordRule)
        case emailNotFound
        case passwordIncorrect
    }
    
    typealias Id = FSUser.UserId
    typealias ResultHandler<T, Error: Swift.Error> = (Result<T, Error>) -> Void

    var currentUser: Box<FSUser?> = .init()

    var userProvider = FSUserProvider()

    func signUp(
        email: String,
        password: String,
        errorHandler: @escaping ResultHandler<Id, SignUpError>
    ) {
        
    }

    func login(
        email: String,
        password: String,
        errorHandler: @escaping (LoginError) -> Void
    ) {
        let name = "小熊貓 \(Int(Date().timeIntervalSince1970))"
        let user = FSUser(id: UUID().uuidString, name: name)
        FSUser.currentUser = user
        FSUserProvider.createNewUser(user: user)
    }
}
