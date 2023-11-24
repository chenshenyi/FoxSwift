//
//  FSViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import UIKit

class FSViewController: UIViewController {
    // MARK: - Debug Button
    #if DEBUG
        private let showDebugToolButton = UIButton()
        private let debugButton = UIButton()
        private let debugTextField = UITextField()
        private var debugToolAction: (_ command: String) -> Void = { _ in }

        private var isDebugToolHidden = false {
            didSet {
                debugButton.isHidden = isDebugToolHidden
                debugTextField.isHidden = isDebugToolHidden
            }
        }

        func setDebugCommand(_ handler: @escaping (_ command: String) -> Void) {
            debugToolAction = handler
        }

        func setupDeubgTool() {
            debugButton.setTitle("Debug", for: .normal)
            debugButton.backgroundColor = .accent

            debugButton.addAction { [weak self] in
                guard let self else { return }
                debugToolAction(debugTextField.text ?? "")
            }

            view.addSubview(debugButton)
            view.bringSubviewToFront(debugButton)
            debugButton.snp.makeConstraints { make in
                make.trailing.top.equalTo(view.safeAreaLayoutGuide)
                make.width.equalTo(70)
                make.height.equalTo(30)
            }

            debugTextField.placeholder = "Debug Command"
            debugTextField.backgroundColor = .black
            debugTextField.textColor = .white

            view.addSubview(debugTextField)
            view.bringSubviewToFront(debugTextField)
            debugTextField.snp.makeConstraints { make in
                make.leading.top.equalTo(view.safeAreaLayoutGuide)
                make.width.equalTo(300)
                make.height.equalTo(30)
            }

            showDebugToolButton.backgroundColor = .clear

            view.addSubview(showDebugToolButton)
            view.bringSubviewToFront(showDebugToolButton)
            showDebugToolButton.snp.makeConstraints { make in
                make.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
                make.height.width.equalTo(10)
            }

            showDebugToolButton.addAction { [weak self] in
                self?.isDebugToolHidden.toggle()
            }

            isDebugToolHidden = true
        }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .fsBg
    }
}
