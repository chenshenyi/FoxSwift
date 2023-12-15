//
//  ProfileViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/6.
//

import UIKit

enum ProfileInvalidField: Error {
    case invalidName
    case invalidDescription
}

class ProfileViewModel {
    // MARK: - Binded Properties
    var name: Box<String> = .init("")
    var description: Box<String> = .init("")
    var email: Box<String> = .init("")
    var picture: Box<UIImage> = .init(.foxWithBubble)
    var banner: Box<UIImage> = .init(.defaultBanner)

    // MARK: - State
    enum State {
        case editing
        case view
    }

    private(set) var state: Box<State> = .init(.view)

    // MARK: - Manager
    let imageProvider = StorageManager.imageManager
    var userProvider: FSUserProvider {
        .shared
    }

    // MARK: - Setup
    func setupUser(user: FSUser) {
        name.value = user.name
        description.value = user.description
        email.value = user.email

        if let url = URL(string: user.picture), user.picture != "Default" {
            fetchImage(url: url, for: .picture)
        } else {
            picture.value = .foxWithBubble
        }

        if let url = URL(string: user.bannerPicture), user.bannerPicture != "Default" {
            fetchImage(url: url, for: .banner)
        } else {
            banner.value = .defaultBanner
        }
    }

    // MARK: - State
    func startEditing() {
        state.value = .editing
    }

    func endEditing() {
        state.value = .view
    }

    // MARK: - StringField
    private enum StringField {
        case name
        case description
        case email
    }

    private func setField(text: String, for stringField: StringField) {
        switch stringField {
        case .name: name.value = text
        case .description: description.value = text
        case .email: email.value = text
        }
    }

    func updateName(text: String?) throws {
        guard let text, text.count >= 2, text.count <= 15 else {
            throw ProfileInvalidField.invalidName
        }
        updateCurrentUser(text: text, for: .name)
    }

    func updateDescription(text: String?) throws {
        guard let text, text.count <= 300 else {
            throw ProfileInvalidField.invalidDescription
        }
        updateCurrentUser(text: text, for: .description)
    }

    private func updateCurrentUser(text: String, for stringField: StringField) {
        switch stringField {
        case .name: FSUser.currentUser?.name = text
        case .description: FSUser.currentUser?.description = text
        case .email: FSUser.currentUser?.email = text
        }
        setField(text: text, for: stringField)
        userProvider.updateCurrentUser()
    }

    // MARK: - ImageField
    private enum ImageField {
        case picture
        case banner
    }

    private func setFiled(image: UIImage, for imageField: ImageField) {
        switch imageField {
        case .banner: banner.value = image
        case .picture: picture.value = image
        }
    }

    private func fetchImage(url: URL, for imageField: ImageField) {
        imageProvider.download(url: url, completion: successHandler { [weak self] data in
            guard let image = UIImage(data: data) else { return }
            self?.setFiled(image: image, for: imageField)
        })
    }

    func updatePicture(image: UIImage) {
        updateCurrentUser(image: image, for: .picture)
    }

    func updateBanner(image: UIImage) {
        updateCurrentUser(image: image, for: .banner)
    }

    private func updateCurrentUser(image: UIImage, for imageField: ImageField) {
        guard let data = image.pngData() else { return }

        setFiled(image: image, for: imageField)
        imageProvider.upload(
            data: data,
            name: "Picture-" + UUID().uuidString,
            completion: successHandler { [weak self] url in
                guard let self else { return }

                switch imageField {
                case .picture:
                    FSUser.currentUser?.picture = url.absoluteString
                    FSUser.currentUser?.smallPicture = image.resizeWithLimit(limit: 50)

                case .banner:
                    FSUser.currentUser?.bannerPicture = url.absoluteString
                }
                userProvider.updateCurrentUser()
            }
        )
    }
}
