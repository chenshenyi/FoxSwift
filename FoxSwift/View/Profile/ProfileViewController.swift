//
//  ProfileViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/6.
//

import UIKit

class ProfileViewController: FSViewController {
    var viewModel = ProfileViewModel()

    // MARK: - Subviews
    let banner = UIImageView()
    let userPicture = UIImageView()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let descriptionTextView = UITextView()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBanner()
        setupUserPicture()
        setupNameTextField()
        setupEmailTextField()
        setupDescriptionTextView()
        bindViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if viewModel.state.value == .editing {
            guard let currentUser = FSUser.currentUser else { return }
            viewModel.setupUser(user: currentUser)
            viewModel.endEditing()
        }
    }

    // MARK: - NavBarButton
    func setupEditButton() {
        let action = UIAction { [weak self] _ in
            self?.viewModel.startEditing()
        }
        let editButton = UIBarButtonItem(systemItem: .edit, primaryAction: action)
        editButton.tintColor = .fsSecondary
        navigationController?.navigationBar.topItem?.setRightBarButton(editButton, animated: false)
    }

    func setupDoneButton() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            saveEditted()
        }
        let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: action)
        doneButton.tintColor = .fsSecondary
        navigationController?.navigationBar.topItem?.setRightBarButton(doneButton, animated: false)
    }

    func saveEditted() {
        do {
            try viewModel.updateName(text: nameTextField.text)
            try viewModel.updateDescription(text: descriptionTextView.text)
            viewModel.endEditing()
        } catch let error as ProfileInvalidField {
            nameTextField.layer.borderWidth = 0
            descriptionTextView.layer.borderWidth = 0

            switch error {
            case .invalidDescription:
                descriptionTextView.layer.borderWidth = 1
                descriptionTextView.layer.borderColor = UIColor.error.cgColor
            case .invalidName:
                nameTextField.layer.borderWidth = 1
                nameTextField.layer.borderColor = UIColor.error.cgColor
            }
        } catch { fatalError("Unknown Error") }
    }

    // MARK: - Binding ViewModel
    func bindViewModel() {
        if let currentUser = FSUser.currentUser {
            viewModel.setupUser(user: currentUser)
        }

        viewModel.name.bind(inQueue: .main) { [weak self] name in
            self?.nameTextField.text = name
        }
        viewModel.email.bind(inQueue: .main) { [weak self] email in
            self?.emailTextField.text = email
        }
        viewModel.description.bind(inQueue: .main) { [weak self] description in
            self?.descriptionTextView.text = description
        }
        viewModel.picture.bind(inQueue: .main) { [weak self] picture in
            self?.userPicture.image = picture
        }
        viewModel.banner.bind(inQueue: .main) { [weak self] banner in
            self?.banner.image = banner
        }
        viewModel.state.bind(inQueue: .main) { [weak self] state in
            guard let self else { return }

            switch state {
            case .view:
                setupEditButton()
                nameTextField.isEnabled = false
                descriptionTextView.isEditable = false
                nameTextField.backgroundColor = .clear
                descriptionTextView.backgroundColor = .clear
                nameTextField.layer.borderWidth = 0
                descriptionTextView.layer.borderWidth = 0
            case .editing:
                setupDoneButton()
                nameTextField.isEnabled = true
                descriptionTextView.isEditable = true
                nameTextField.backgroundColor = .fsPrimary
                descriptionTextView.backgroundColor = .fsPrimary
            }
        }
    }

    // MARK: - Setup subviews
    func setupBanner() {
        banner.addTo(view) { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
    }

    func setupUserPicture() {
        userPicture.backgroundColor = .fsBg
        userPicture.layer.cornerRadius = 50
        userPicture.layer.masksToBounds = true
        userPicture.layer.borderWidth = 4
        userPicture.layer.borderColor = UIColor.fsSecondary.cgColor
        userPicture.addTo(view) { make in
            make.top.equalTo(banner.snp.bottom).offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(100)
        }
    }

    func setupNameTextField() {
        nameTextField.textColor = .accent
        nameTextField.font = .config(weight: .bold, size: 24)
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.cornerRadius = 5
        nameTextField.addTo(view) { make in
            make.centerY.equalTo(userPicture)
            make.leading.equalTo(userPicture.snp.trailing).offset(15)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
    }

    func setupEmailTextField() {
        emailTextField.font = .config(weight: .regular, size: 16)
        emailTextField.textColor = .fsText
        emailTextField.layer.masksToBounds = true
        emailTextField.layer.cornerRadius = 5
        emailTextField.addTo(view) { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(5)
            make.leading.equalTo(nameTextField)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
    }

    func setupDescriptionTextView() {
        descriptionTextView.font = .config(weight: .regular, size: 16)
        descriptionTextView.textColor = .fsText
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.addTo(view) { make in
            make.top.equalTo(userPicture.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
    }
}
