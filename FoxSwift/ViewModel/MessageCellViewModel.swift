//
//  MessageCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import Foundation

class MessageCellViewModel {
    var author: Box<String> = .init("")
    var content: Box<String> = .init("")
    
    func setup(message: FSMessage) {
        author.value = message.author.name
        let data = message.data
        let text = String(data: data, encoding: .utf8) ?? ""
        content.value = text
    }
}
