//
//  ProfileViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/6.
//

import PhotosUI
import UIKit

class ProfileViewController: FSViewController {
    var viewModel = ProfileViewModel()

    // MARK: - Subviews
    let banner = UIImageView()
    let editBannerButton = UIButton()
    let userPicture = UIImageView()
    let editPictureButton = UIButton()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let descriptionTextView = UITextView()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBanner()
        setupEditBannerButton()
        setupUserPicture()
        setupEditPictureButton()
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
                editBannerButton.isHidden = true
                editPictureButton.isHidden = true
                nameTextField.isEnabled = false
                descriptionTextView.isEditable = false
                nameTextField.backgroundColor = .clear
                descriptionTextView.backgroundColor = .clear
                nameTextField.layer.borderWidth = 0
                descriptionTextView.layer.borderWidth = 0
            case .editing:
                setupDoneButton()
                editBannerButton.isHidden = false
                editPictureButton.isHidden = false
                nameTextField.isEnabled = true
                descriptionTextView.isEditable = true
                nameTextField.backgroundColor = .fsPrimary
                descriptionTextView.backgroundColor = .fsPrimary
            }
        }
    }

    // MARK: - Setup subviews
    func setupBanner() {
        banner.backgroundColor = .fsBg
        banner.contentMode = .scaleAspectFill
        banner.clipsToBounds = true
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
        userPicture.contentMode = .scaleAspectFill
        userPicture.clipsToBounds = true
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
        nameTextField.setToolBar()
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
        emailTextField.setToolBar()
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
        descriptionTextView.setToolBar()
        descriptionTextView.addTo(view) { make in
            make.top.equalTo(userPicture.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
    }

    // MARK: Setup Edit Button
    var didGetImage: ((_ image: UIImage) -> Void)?

    func setupEditBannerButton() {
        editBannerButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        editBannerButton.tintColor = .fsSecondary
        editBannerButton.backgroundColor = .fsPrimary
        editBannerButton.layer.cornerRadius = 15
        editBannerButton.addTo(view) { make in
            make.bottom.trailing.equalTo(banner)
            make.size.equalTo(30)
        }

        editBannerButton.addAction { [weak self] in
            guard let self else { return }

            didGetImage = { [weak self] image in
                guard let self else { return }
                viewModel.updateBanner(image: image)
            }
            selectImage()
        }
    }

    func setupEditPictureButton() {
        editPictureButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        editPictureButton.tintColor = .fsSecondary
        editPictureButton.backgroundColor = .fsPrimary
        editPictureButton.layer.cornerRadius = 15
        editPictureButton.addTo(view) { make in
            make.bottom.trailing.equalTo(userPicture)
            make.size.equalTo(30)
        }

        editPictureButton.addAction { [weak self] in
            guard let self else { return }

            didGetImage = { [weak self] image in
                guard let self else { return }
                viewModel.updatePicture(image: image)
            }
            selectImage()
        }
    }

    func selectImage() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let phViewController = PHPickerViewController(configuration: config)
        phViewController.delegate = self
        present(phViewController, animated: true)
    }
}

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let first = results.first else { return }

        first.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in

            DispatchQueue.main.async {
                if error != nil {
                    self?.popup(text: "Invalid Format", style: .error, completion: {})
                    return
                }
                
                guard let image = image as? UIImage else {
                    self?.popup(text: "Invalid Format", style: .error, completion: {})
                    return
                }
                
                self?.popup(text: "Success", style: .checkmark, completion: {})
                self?.didGetImage?(image)
            }
        }
    }
}
