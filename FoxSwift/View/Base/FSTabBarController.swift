//
//  FSTabBarController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/14.
//

import UIKit

class FSTabBarController: UITabBarController {
    var tabs: [Tab] = [.meets, .records, .history, .profile]
    var tabsDict: [Tab: UIViewController] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        checkLogin()
    }

    func setupTabBar() {
        tabs.forEach { tab in
            tabsDict[tab] = tab.viewController
        }

        viewControllers = tabs.map { tab in
            guard let viewController = tabsDict[tab] else { fatalError("unknown error") }

            viewController.tabBarItem.image = tab.image
            viewController.tabBarItem.title = tab.localizedDescription
            viewController.navigationItem.title = tab.localizedDescription

            let nav = FSNavigationController(rootViewController: viewController)
            return nav
        }

        tabBar.unselectedItemTintColor = .G_3

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor.fsPrimary
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    func checkLogin() {
    }
}


extension FSTabBarController {
    enum Tab: Localizable {
        case meets
        case records
        case history
        case profile

        var localizedDescription: String {
            switch self {
            case .meets: return "Meets"
            case .records: return "Records"
            case .history: return "History"
            case .profile: return "Profile"
            }
        }

        var image: UIImage? {
            switch self {
            case .meets: return .init(systemName: "person.2.wave.2")
            case .records: return .init(systemName: "filemenu.and.selection")
            case .history: return .init(systemName: "clock.arrow.circlepath")
            case .profile: return .init(systemName: "person.circle")
            }
        }

        var viewController: FSViewController {
            switch self {
            case .meets: return MeetsViewController()
            case .profile: return ProfileViewController()
            case .records: return RecordsViewController()
            case .history: return HistoryViewController()
            }
        }
    }
}
