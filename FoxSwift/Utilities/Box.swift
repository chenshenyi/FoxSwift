//
//  Box.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

final class Box<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?
    private var queue: DispatchQueue?

    var value: T {
        didSet {
            if let queue {
                queue.async { [weak self] in
                    guard let self else { return }
                    listener?(value)
                }
            } else {
                listener?(value)
            }
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(inQueue queue: DispatchQueue? = nil, listener: Listener?) {
        self.listener = listener
        self.queue = queue
        listener?(value)
    }
}
