//
//  LoginRule.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import Foundation

// MARK: - Rule
private protocol Rule: Localizable {
    associatedtype Parameters

    var check: (Parameters) -> Bool { get }
}

// MARK: - Email Rule
enum EmailRule: Rule, CaseIterable {
    case notEmpty

    var localizedDescription: String {
        "Email empty."
    }

    typealias Email = String

    var check: (Email) -> Bool {
        { email in !email.isEmpty }
    }
}

// MARK: - Password Rule
enum PasswordRule: Rule, CaseIterable {
    case notEmpty
    case notSameToEmail

    typealias Email = String
    typealias Password = String
    typealias Parameters = (email: Email, password: Password)

    var localizedDescription: String {
        switch self {
        case .notEmpty: "Password empty."
        case .notSameToEmail: "Password invalid."
        }
    }

    var check: (Parameters) -> Bool {
        switch self {
        case .notEmpty: { arg in !arg.password.isEmpty }
        case .notSameToEmail: { arg in arg.email != arg.password }
        }
    }
}

// MARK: - User Name Rule
enum UserNameRule: Rule, CaseIterable {
    case notEmpty

    typealias UserName = String

    var localizedDescription: String {
        "Name empty."
    }

    var check: (UserName) -> Bool {
        { userName in !userName.isEmpty }
    }
}
