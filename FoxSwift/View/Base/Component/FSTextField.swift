//
//  FSTextField.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/10.
//

import UIKit

class FSTextField: UITextField {
    convenience init() {
        self.init(frame: .zero)
        
        backgroundColor = .fsBg
        borderStyle = .line
        layer.borderColor = UIColor.fsSecondary.cgColor
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 4, dy: 4)
    }
}
