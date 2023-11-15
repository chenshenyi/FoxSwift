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

        navigationBar.backgroundColor = .fsPrimary

        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.fsText]
    }
}
