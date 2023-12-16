//
//  TextStyles.swift
//  STYLiSH
//
//  Created by chen shen yi on 2023/9/27.
//

import UIKit

extension UIFont {
    static func config(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        let weightString = {
            switch weight {
            case .ultraLight: return "UltraLight"
            case .thin: return "Thin"
            case .light: return "Light"
            case .regular: return "Regular"
            case .medium: return "Medium"
            case .semibold: return "Semibold"
            case .bold: return "Bold"
            case .heavy: return "Heavy"
            case .black: return "Black"
            default: return ""
            }
        }()

        return UIFont(name: "PingFang TC \(weightString)", size: size)
            ?? UIFont(name: "PingFang TC", size: size)
            ?? systemFont(ofSize: size, weight: weight)
    }
}
