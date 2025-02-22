//
//  RandomGeneratable.swift
//  fox-swift-server
//
//  Created by chen shen yi on 2025/2/22.
//

import Foundation

func rand<each T: RandomGeneratable>() -> (repeat each T) {
    (repeat (each T).rand)
}

func rand<each T: RandomGeneratable>(index: Int) -> (repeat each T) {
    (repeat (each T).rand(index: index))
}

func rands<each T: RandomGeneratable>(amount: Int) -> [(repeat (each T))] {
    (0..<amount).map(rand(index:))
}

protocol RandomGeneratable {
    static var rand: Self { get }
    static func rand(index: Int) -> Self
    static func rands(amount: Int) -> [Self]
}

extension RandomGeneratable {
    static func rand(index: Int) -> Self {
        rand
    }

    static func rands(amount: Int) -> [Self] {
        (0..<amount).map(rand(index:))
    }
}

extension UUID: RandomGeneratable {
    static var rand: UUID {
        .generateRandom()
    }
}
