//
//  MessageCellViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import Foundation

class FSMessageViewModel {
    var authorName: Box<String> = .init("")
    var isMyMessage: Box<Bool> = .init(false)
    
    func setup(message: FSMessage) {
        isMyMessage.value = message.author.id == Participant.currentUser.id
        
        authorName.value = message.author.name
    }
}

