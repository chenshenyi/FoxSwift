//
//  FSNavigationController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import UIKit

class FSNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .fsPrimary
        appearance.titleTextAttributes = [.foregroundColor: UIColor.fsText]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
