//
//  Error+Extenision.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/27.
//

import Foundation

extension Error {
    func print() {
        Swift.print(self.localizedDescription.red)
    }
}
