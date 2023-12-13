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

    var loadingViews: [String: UIView] = [:] {
        didSet {
            if loadingViews.isEmpty {
                view.isUserInteractionEnabled = true
            } else {
                view.isUserInteractionEnabled = false
            }
        }
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

    func startLoadingView(text: String = "Loading...", id: String) {
        let loadingView = UIView()
        loadingView.backgroundColor = .fsSecondary

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            loadingViews[id] = loadingView
            loadingView.addTo(view) { make in
                make.center.equalToSuperview()
                make.size.equalTo(60)
            }
        }
    }

    func stopLoadingView(id: String) {
        guard let loadingView = loadingViews[id] else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            loadingViews[id] = nil
            loadingView.removeFromSuperview()
        }
    }
}
