//
//  LoginFlowManager.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/13.
//

import UIKit

class LoginFlowManager {
    static let shared = LoginFlowManager()

    let keyChainManager = KeyChainManager()
    let userProvider = FSUserProvider.shared
    var rootViewController: UIViewController?

    func startLoginFlow(didCheckLogin: @escaping (_ isSuccess: Bool) -> Void) {
        if let user = keyChainManager.loadUser() {
            userProvider.login(email: user.email, password: user.password) { [weak self] result in
                guard let self else { return }

                switch result {
                case let .success(user):
                    FSUser.currentUser = user
                    userProvider.activeListener(currentUser: user)
                    didCheckLogin(true)

                case .failure:
                    didCheckLogin(false)
                    showLoginPage()
                }
            }
        } else {
            didCheckLogin(false)
            showLoginPage()
        }
    }

    private func showLoginPage() {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        rootViewController?.present(loginViewController, animated: true)
    }
}
