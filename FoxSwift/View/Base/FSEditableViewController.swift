//
//  FSEditableViewController.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/9.
//

import UIKit

protocol FSEditableViewModel: AnyObject {
    var isEditing: Box<Bool> { get set }

    func startEdit()

    func stopEdit()
}

extension FSEditableViewModel {
    func startEdit() {
        isEditing.value = true
    }

    func stopEdit() {
        isEditing.value = false
    }
}

protocol FSEditableViewController: UIViewController {
    associatedtype ViewModel: FSEditableViewModel

    var viewModel: ViewModel { get }

    var editButton: UIBarButtonItem { get }

    var doneButton: UIBarButtonItem { get }

    func startEdit()

    func stopEdit()
}

extension FSEditableViewController {
    func setupEditable() {
        setupEditButton()
        setupDoneButton()
        showEditButton()
        viewModel.isEditing.bind(inQueue: .main) { [weak self] value in
            guard let self else { return }

            if value {
                showDoneButton()
                startEdit()
            } else {
                showEditButton()
                stopEdit()
            }
        }
    }

    func setupEditButton() {
        editButton.primaryAction = UIAction { [weak self] _ in
            self?.viewModel.startEdit()
        }
        editButton.tintColor = .accent
    }

    func showEditButton() {
        navigationController?.navigationBar.topItem?.setRightBarButton(editButton, animated: false)
    }

    func setupDoneButton() {
        doneButton.primaryAction = UIAction { [weak self] _ in
            self?.viewModel.stopEdit()
        }
        doneButton.tintColor = .accent
    }

    func showDoneButton() {
        navigationController?.navigationBar.topItem?.setRightBarButton(doneButton, animated: false)
    }
}
