//
//  FSTextMessageViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/4.
//

import Foundation

class FSTextMessageViewModel: FSMessageViewModel {
    var content: Box<String> = .init("")

    override func setup(message: FSMessage) {
        super.setup(message: message)
        
        let data = message.data
        let text = String(data: data, encoding: .utf8) ?? ""
        content.value = text
    }
}
