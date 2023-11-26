//
//  UITextView+Extension.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/26.
//

import UIKit

extension UITextView {
    func setToolBar() {
        inputAccessoryView = toolBar()
    }

    func toolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = .fsPrimary

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(onClickDoneButton)
        )
        doneButton.tintColor = .success
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }

    @objc func onClickDoneButton() {
        endEditing(true)
    }
}
