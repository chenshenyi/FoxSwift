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

    private var semaphore: DispatchSemaphore?

    var value: T {
        willSet {
            semaphore?.wait()
        }
        didSet {
            if let queue {
                queue.async { [weak self] in
                    guard let self else { return }
                    listener?(value)
                    semaphore?.signal()
                }
            } else {
                listener?(value)
                semaphore?.signal()
            }
        }
    }

    init(_ value: T, semaphore: Int? = nil) {
        self.value = value
        if let semaphore {
            self.semaphore = .init(value: semaphore)
        }
    }

    init<K>(semaphore: Int? = nil) where T == K? {
        value = nil
        if let semaphore {
            self.semaphore = .init(value: semaphore)
        }
    }

    func bind(inQueue queue: DispatchQueue? = nil, listener: Listener?) {
        self.listener = listener
        self.queue = queue
        listener?(value)
    }
}
