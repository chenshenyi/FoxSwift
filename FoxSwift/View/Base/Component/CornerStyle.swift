//
//  CornerStyle.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/11.
//

import UIKit

extension UIView {
    enum CornerStyle {
        case squared
        case rounded
        case roundSquared(Int)
    }
}

protocol CornerStyled: UIView {
    var cornerStyle: CornerStyle { get }
}

extension CornerStyled {
    func setupCornerRaius() {
        switch cornerStyle {
        case .rounded: layer.cornerRadius = bounds.height / 2
        case .squared: layer.cornerRadius = 0
        case .roundSquared(let radius): layer.cornerRadius = CGFloat(radius)
        }
    }
}
