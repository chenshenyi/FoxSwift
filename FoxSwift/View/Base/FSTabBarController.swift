//
//  FSTabBarController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/14.
//

import UIKit

class FSTabBarController: UITabBarController {
    let tabs: [Tab] = [.meets, .records, .history, .profile]

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map { tab in
            let viewController = tab.viewController
            viewController.tabBarItem.image = tab.image
            viewController.tabBarItem.title = tab.localizedDescription
            viewController.navigationItem.title = tab.localizedDescription

            let nav = FSNavigationController(rootViewController: viewController)
            return nav
        }

        tabBar.backgroundColor = .fsPrimary
        tabBar.unselectedItemTintColor = .G_3
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
            default: return FSViewController()
            }
        }
    }
}
