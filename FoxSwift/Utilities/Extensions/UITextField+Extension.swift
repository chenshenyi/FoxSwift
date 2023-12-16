//
//  UITextField+Extension.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/17.
//

import UIKit

extension UITextField {
    func setToolBar() {
        inputAccessoryView = toolBar()
    }

    func toolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = .fsPrimary

        let label = UILabel()
        label.textColor = .fsText
        label.text = placeholder

        let placeHolder = UIBarButtonItem(customView: label)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(onClickDoneButton)
        )
        doneButton.tintColor = .success
        toolBar.setItems([space, placeHolder, space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }

    @objc func onClickDoneButton() {
        endEditing(true)
    }
}
