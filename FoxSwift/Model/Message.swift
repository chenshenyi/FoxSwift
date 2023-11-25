//
//  Message.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import Foundation

struct FSMessage: Codable {
    enum FSMessageType: Codable {
        case text
        case image
        case file
    }

    enum CodingKeys: CodingKey {
        case data
        case author
        case type
        case createdTime
    }

    var data: Data
    var author: Participant
    var type: FSMessageType
    var createdTime: Int

    init(data: Data, author: Participant, type: FSMessageType) {
        self.data = data
        self.author = author
        self.type = type
        createdTime = Int(Date.now.timeIntervalSince1970)
    }
}
