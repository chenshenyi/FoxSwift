//
//  SceneDelegate.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        intialize(scene)

        guard let url = connectionOptions.urlContexts.first?.url else { return }
        UrlRouteManager.shared.open(url: url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        intialize(scene)

        guard let url = URLContexts.first?.url else { return }
        UrlRouteManager.shared.open(url: url)
    }

    func intialize(_ scene: UIScene) {
        guard let scene = (scene as? UIWindowScene) else { fatalError("Unknown scene") }
        window = UIWindow(windowScene: scene)
        let tabBarController = FSTabBarController()

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        let keyChainManager = KeyChainManager()
        UrlRouteManager.shared.rootViewController = tabBarController

        if let user = keyChainManager.loadUser() {
            FSUser.currentUser = user

            FSUserProvider.shared.login(
                email: user.email,
                password: user.password
            ) { result in

                switch result {
                case let .success(user):
                    FSUser.currentUser = user

                case .failure:
                    DispatchQueue.main.async {
                        let loginViewController = LoginViewController()
                        loginViewController.modalPresentationStyle = .fullScreen
                        tabBarController.present(loginViewController, animated: false)
                    }
                }
            }
        } else {
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            tabBarController.present(loginViewController, animated: false)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
