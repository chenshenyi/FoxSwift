//
//  FSTextField.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/10.
//

import UIKit

class FSTextField: UITextField, CornerStyled {
    var cornerStyle: CornerStyle = .rounded

    var onError = false {
        didSet {
            if onError {
                layer.borderWidth = 2
                layer.borderColor = UIColor.red.cgColor
            } else {
                layer.borderWidth = 1
                layer.borderColor = UIColor.fsSecondary.cgColor
            }
        }
    }

    var inset: CGFloat {
        switch cornerStyle {
        case .squared: 8
        case .rounded: bounds.height / 2
        case .roundSquared(let radius): CGFloat(radius)
        }
    }

    convenience init(placeholder: String) {
        self.init(frame: .zero)

        self.placeholder = placeholder
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.G_3]
        )
        backgroundColor = .fsPrimary
        borderStyle = .line
        textColor = .fsText
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.fsSecondary.cgColor

        setToolBar()
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 4)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 4)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupCornerRaius()
    }
}
