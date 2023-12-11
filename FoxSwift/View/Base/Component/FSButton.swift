//
//  FSButton.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import UIKit

class FSButton: UIButton {
    enum ButtonStyle {
        case outline(color: UIColor)
        case filled(color: UIColor, textColor: UIColor)
    }

    private(set) var style: ButtonStyle = .outline(color: .accent)

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }

    func setupStyle(style: ButtonStyle) {
        switch style {
        case let .filled(color, textColor):
            backgroundColor = color
            layer.borderWidth = 0
            setTitleColor(textColor, for: .normal)
        case .outline(let color):
            backgroundColor = .clear
            layer.borderColor = color.cgColor
            layer.borderWidth = 1
            setTitleColor(color, for: .normal)
        }
    }
}
