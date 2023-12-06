//
//  ProfileViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/6.
//

import UIKit

class ProfileViewModel {
    // MARK: - Binded Properties
    var name: Box<String> = .init("")
    var description: Box<String> = .init("")
    var email: Box<String> = .init("")
    var picture: Box<UIImage> = .init(.foxWithBubble)
    var banner: Box<UIImage> = .init(.defaultBanner)

    // MARK: - Manager
    let imageProvider = StorageManager.imageManager
    let userProvider = FSUserProvider()

    // MARK: - Setup
    func setupUser(user: FSUser) {
        name.value = user.name
        description.value = user.description
        email.value = user.email

        if let url = URL(string: user.picture),
           user.picture != "Default"
        {
            fetchImage(url: url, for: .picture)
        } else {
            picture.value = .foxWithBubble
        }

        if let url = URL(string: user.bannerPicture),
           user.bannerPicture != "Default"
        {
            fetchImage(url: url, for: .banner)
        } else {
            banner.value = .defaultBanner
        }
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
    
    func updateName(text: String) {
        updateCurrentUser(text: text, for: .name)
    }
    
    func updateDescription(text: String) {
        updateCurrentUser(text: text, for: .description)
    }
    
    func updateEmail(text: String) {
        updateCurrentUser(text: text, for: .email)
    }
    
    private func updateCurrentUser(text: String, for stringField: StringField) {
        switch stringField {
        case .name: FSUser.currentUser?.name = text
        case .description: FSUser.currentUser?.description = text
        case .email: FSUser.currentUser?.email = text
        }
        userProvider.updateCurrentUser()
        setField(text: text, for: stringField)
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
        imageProvider.upload(
            data: data,
            name: "Picture-" + UUID().uuidString,
            completion: successHandler { [weak self] url in
                guard let self else { return }

                switch imageField {
                case .picture:
                    FSUser.currentUser?.picture = url.absoluteString
                case .banner:
                    FSUser.currentUser?.bannerPicture = url.absoluteString
                }
                userProvider.updateCurrentUser()
                fetchImage(url: url, for: imageField)
            }
        )
    }
}
