//
//  Message.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/25.
//

import Foundation
import UIKit

struct FSMessage: Codable, Identifiable {
    enum FSMessageType: Codable {
        case text
        case image
        case imageUrl
        case file
        case fileUrl
        case speechText
    }

    enum CodingKeys: CodingKey {
        case id
        case data
        case author
        case type
        case createdTime
    }

    var id: String
    var data: Data
    var author: Participant
    var type: FSMessageType
    var createdTime: Int

    init(
        id: ID = UUID().uuidString,
        data: Data,
        author: Participant,
        type: FSMessageType
    ) {
        self.id = id
        self.data = data
        self.author = author
        self.type = type
        createdTime = Int(Date.now.timeIntervalSince1970)
    }

    init?(string: String, type: FSMessageType) {
        guard let data = string.data(using: .utf8) else { return nil }
        self.init(data: data, author: Participant.currentUser, type: type)
    }
}
