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
        setupTextFields()
        setupStackView()
        setupConfirmButton()
        setupConstraint()

        loginMode = .login
    }

    // MARK: Update UI by result
    private func resetTextFieldOnError() {
        nameTextField.onError = false
        emailTextField.onError = false
        passwordTextField.onError = false
    }

    private func enableInteraction() {
        confirmButton.isUserInteractionEnabled = true
    }

    private func dismiss() {
        dismiss(animated: true)
    }

    func loginResultHandler(result: LoginViewModel.LoginResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            resetTextFieldOnError()

            stopLoadingView(id: LoginMode.login.localizedDescription)

            switch result {
            case .success:
                popup(text: "Success", style: .checkmark, completion: dismiss)

            case let .failure(.invalidEmail(rule: rule)):
                emailTextField.onError = true
                popup(text: rule.localizedDescription, style: .error, completion: enableInteraction)

            case let .failure(.invalidPassword(rule: rule)):
                passwordTextField.onError = true
                popup(text: rule.localizedDescription, style: .error, completion: enableInteraction)

            case .failure(.passwordIncorrect):
                passwordTextField.onError = true
                popup(text: "Password incorrect", style: .error, completion: enableInteraction)


            case .failure(.emailNotFound):
                emailTextField.onError = true
                popup(text: "Email not found", style: .error, completion: enableInteraction)

            case .failure(.unknownError):
                fatalError("Unknow error when login")
            }
        }
    }

    func signUpResultHandler(result: LoginViewModel.SignUpResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            resetTextFieldOnError()
            stopLoadingView(id: LoginMode.signUp.localizedDescription)

            switch result {
            case .success:
                popup(text: "Success", style: .checkmark, completion: dismiss)

            case let .failure(.invalidUserName(rule: rule)):
                nameTextField.onError = true
                popup(text: rule.localizedDescription, style: .error, completion: enableInteraction)

            case let .failure(.invalidEmail(rule: rule)):
                emailTextField.onError = true
                popup(text: rule.localizedDescription, style: .error, completion: enableInteraction)

            case let .failure(.invalidPassword(rule: rule)):
                passwordTextField.onError = true
                popup(text: rule.localizedDescription, style: .error, completion: enableInteraction)

            case .failure(.emailExist):
                emailTextField.onError = true
                popup(text: "Email already exist", style: .error, completion: enableInteraction)

            case .failure(.unknownError):
                fatalError("Unknow error when login")
            }
        }
    }

    private func confirmButtonTapped() {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        confirmButton.isUserInteractionEnabled = false

        switch loginMode {
        case .login: login(email: email, password: password)
        case .signUp: signUp(name: name, email: email, password: password)
        }
    }

    func login(email: String, password: String) {
        startLoadingView(id: LoginMode.login.localizedDescription)
        viewModel.login(email: email, password: password, handler: loginResultHandler)
    }

    func signUp(name: String, email: String, password: String) {
        startLoadingView(id: LoginMode.signUp.localizedDescription)
        viewModel.signUp(
            email: email,
            password: password,
            userName: name,
            handler: signUpResultHandler
        )
    }

    // MARK: Setup Subviews
    private func setuptitleLabel() {
        titleLabel.text = "Welcome to FoxSwift"
        titleLabel.textColor = .accent
        titleLabel.font = .config(weight: .black, size: 30)
    }

    private func setupSelectionView() {
        modeSelectionView.dataSource = self
        modeSelectionView.delegate = self
    }

    private func setupTextFields() {
        nameTextField.textContentType = .name
        emailTextField.textContentType = .emailAddress
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
    }

    private func setupConfirmButton() {
        confirmButton.setupStyle(style: .filled(color: .accent, textColor: .fsBg))
        confirmButton.addAction(handler: confirmButtonTapped)
    }

    private func setupStackView() {
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

    private func setupConstraint() {
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
