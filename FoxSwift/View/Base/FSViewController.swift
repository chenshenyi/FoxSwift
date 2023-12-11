//
//  FSViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import UIKit

class FSViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .fsBg
    }

    func alertError(text: String) {
        let alert = UIAlertController(
            title: "Error",
            message: text,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )

        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
