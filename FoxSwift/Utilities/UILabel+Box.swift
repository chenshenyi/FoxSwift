//
//  BoxBindingExtension.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import UIKit

extension UILabel {
    func bind(_ box: Box<String>) {
        box.bind { [weak self] title in
            self?.text = title
        }
    }

    func bind<T>(_ box: Box<T>, decorate: @escaping (_ value: T) -> String) {
        box.bind { [weak self] boxValue in
            self?.text = decorate(boxValue)
        }
    }
}
