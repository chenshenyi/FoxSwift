//
//  FSTextMessageViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/4.
//

import Foundation

class FSTextMessageViewModel {
    var authorName: Box<String> = .init("")
    var isMyMessage: Box<Bool> = .init(false)
    var content: Box<String> = .init("")

    func setup(message: FSMessage) {
        isMyMessage.value = message.author.id == Participant.currentUser.id

        authorName.value = message.author.name
        
        let data = message.data
        let text = String(data: data, encoding: .utf8) ?? ""
        content.value = text
    }
}
