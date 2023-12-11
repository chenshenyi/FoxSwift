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

    var viewModel = LoginViewModel()

    // MARK: Subviews
    let titleLabel = UILabel()
    let modeSelectionView = SelectionView()
    let stackView = UIStackView()

    let nameTextField = FSTextField(placeholder: "Name")
    let emailTextField = FSTextField(placeholder: "Email")
    let passwordTextField = FSTextField(placeholder: "Password")
    let confirmButton = FSButton()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setuptitleLabel()
        setupSelectionView()
        setupStackView()
        setupConfirmButton()
        setupConstraint()

        loginMode = .login
    }

    // MARK: Update UI by result
    func loginResultHandler(result: LoginViewModel.LoginResult) {
        emailTextField.onError = false
        passwordTextField.onError = false

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            switch result {
            case let .success(user):
                FSUser.currentUser = user
                dismiss(animated: true)

            case let .failure(.invalidEmail(rule: rule)):
                emailTextField.onError = true
                alertError(text: rule.localizedDescription)

            case let .failure(.invalidPassword(rule: rule)):
                passwordTextField.onError = true
                alertError(text: rule.localizedDescription)

            case .failure(.passwordIncorrect):
                passwordTextField.onError = true
                alertError(text: "Password incorrect")

            case .failure(.emailNotFound):
                emailTextField.onError = true
                alertError(text: "Email not found")

            case .failure(.unknownError):
                fatalError("Unknow error when login")
            }
        }
    }

    func signUpResultHandler(result: LoginViewModel.SignUpResult) {
        nameTextField.onError = false
        emailTextField.onError = false
        passwordTextField.onError = false

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            switch result {
            case let .success(user):
                FSUser.currentUser = user
                dismiss(animated: true)

            case let .failure(.invalidUserName(rule: rule)):
                nameTextField.onError = true
                alertError(text: rule.localizedDescription)

            case let .failure(.invalidEmail(rule: rule)):
                emailTextField.onError = true
                alertError(text: rule.localizedDescription)

            case let .failure(.invalidPassword(rule: rule)):
                passwordTextField.onError = true
                alertError(text: rule.localizedDescription)

            case .failure(.emailExist):
                emailTextField.onError = true
                alertError(text: "Email already exist")

            case .failure(.unknownError):
                fatalError("Unknow error when login")
            }
        }
    }

    // MARK: Setup Subviews
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

        confirmButton.addAction { [weak self] in
            guard let self else { return }

            let name = nameTextField.text ?? ""
            let email = emailTextField.text ?? ""
            let password = passwordTextField.text ?? ""

            switch loginMode {
            case .login:
                viewModel.login(
                    email: email,
                    password: password,
                    handler: loginResultHandler
                )
            case .signUp:
                viewModel.signUp(
                    email: email,
                    password: password,
                    userName: name,
                    handler: signUpResultHandler
                )
            }
        }
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

// MARK: - SelectionViewDataSource
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

// MARK: - SelectionViewDelegate
extension LoginViewController: SelectionViewDelegate {
    func selectionDidSelect(_ selectionView: SelectionView, forIndex index: Int) {
        loginMode = LoginMode.allCases[index]
    }
}
