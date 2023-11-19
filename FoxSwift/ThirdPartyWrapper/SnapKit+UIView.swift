//
//  SnapKit+Extension.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/18.
//

import SnapKit
import UIKit

extension UIView {
    func addTo(_ view: UIView, _ makeConstraintsClosure: (_ make: ConstraintMaker) -> Void) {
        view.addSubview(self)
        self.snp.makeConstraints(makeConstraintsClosure)
    }
}
