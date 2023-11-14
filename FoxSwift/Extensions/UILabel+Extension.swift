//
//  UILabel+Extension.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/3.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

extension UILabel {

    var characterSpacing: CGFloat {
        get {
            let kern = attributedText?.value(forKey: NSAttributedString.Key.kern.rawValue) as? CGFloat
            return kern ?? 0
        }
        set {
            if let labelText = text, labelText.count > 0 {
                let attributedString = NSMutableAttributedString(attributedString: attributedText!)
                attributedString.addAttribute(
                    NSAttributedString.Key.kern,
                    value: newValue,
                    range: NSRange(location: 0, length: attributedString.length - 1)
                )
                attributedText = attributedString
            }
        }
    }
}
