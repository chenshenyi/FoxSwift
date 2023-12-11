//
//  LoginViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/10.
//

import UIKit

final class LoginViewController: FSViewController {
    enum LoginMode: Localizable, CaseIterable {
        case login
        case signUp

        var allCases: [Self] { [.login, .signUp] }

        var localizedDescription: String {
            switch self {
            case .login: "Log In"
            case .signUp: "Sign Up"
            }
        }
    }

    var loginMode: LoginMode = .login {
        didSet {
            nameTextField.isHidden = loginMode == .login

            let title = NSAttributedString(
                string: loginMode.localizedDescription,
                attributes: [
                    .font: UIFont.config(weight: .bold, size: 18)
                ]
            )
            confirmButton.setAttributedTitle(title, for: .normal)
        }
    }

    // MARK: Subviews
    let titleLabel = UILabel()
    let modeSelectionView = SelectionView()
    let stackView = UIStackView()

    let nameTextField = FSTextField(placeholder: "Name")
    let emailTextField = FSTextField(placeholder: "Email")
    let passwordTextField = FSTextField(placeholder: "Password")
    let confirmButton = FSButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        setuptitleLabel()
        setupSelectionView()
        setupStackView()
        setupConfirmButton()
        setupConstraint()
        loginMode = .login
    }
    
    func setuptitleLabel() {
        titleLabel.text = "Welcome to FoxSwift"
        titleLabel.textColor = .accent
        titleLabel.font = .config(weight: .black, size: 30)
    }

    func setupSelectionView() {
        modeSelectionView.dataSource = self
        modeSelectionView.delegate = self
    }

    func setupConfirmButton() {
        confirmButton.setupStyle(style: .filled(color: .accent, textColor: .fsBg))
    }

    func setupStackView() {
        stackView.backgroundColor = .fsPrimary

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 24

        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        stackView.layer.cornerRadius = 15
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOffset = .init(width: 4, height: 4)
        stackView.layer.shadowRadius = 4
        stackView.layer.shadowOpacity = 1

        stackView.isLayoutMarginsRelativeArrangement = true
    }

    func setupConstraint() {
        stackView.addTo(view) { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
        }

        modeSelectionView.addTo(view) { make in
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(stackView.snp.top).offset(-30)
        }

        titleLabel.addTo(view) { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(modeSelectionView.snp.top).offset(-30)
        }

        [
            nameTextField,
            emailTextField,
            passwordTextField,
            confirmButton
        ].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(30)
                stackView.addArrangedSubview(view)
            }
        }
    }
}

extension LoginViewController: SelectionViewDataSource {
    func numberOfSelections(_ selectionView: SelectionView) -> Int {
        LoginMode.allCases.count
    }

    func title(_ selectionView: SelectionView, forIndex index: Int) -> String {
        LoginMode.allCases[index].localizedDescription
    }

    func textColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        .fsSecondary
    }

    func indicatorColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        .fsSecondary
    }
}

extension LoginViewController: SelectionViewDelegate {
    func selectionDidSelect(_ selectionView: SelectionView, forIndex index: Int) {
        loginMode = LoginMode.allCases[index]
    }
}
