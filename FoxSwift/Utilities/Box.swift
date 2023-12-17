//
//  Box.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/15.
//

import Foundation

final class Box<T> {
    typealias Listener = (T) -> Void

    private struct BoxListener {
        var listener: Listener
        var queue: DispatchQueue?
        var semaphoreSignal: Bool
    }

    private var boxListener: BoxListener?

    var semaphore: DispatchSemaphore?

    var value: T {
        willSet {
            semaphore?.wait()
        }
        didSet {
            if let boxListener {
                callBoxListener(boxListener: boxListener)
            }
        }
    }

    private func callBoxListener(boxListener: BoxListener) {
        guard let queue = boxListener.queue else {
            boxListener.listener(value)
            if boxListener.semaphoreSignal {
                semaphore?.signal()
            }
            return
        }

        queue.async { [weak self] in
            guard let self else { return }
            boxListener.listener(value)
            if boxListener.semaphoreSignal {
                semaphore?.signal()
            }
        }
    }

    init(_ value: T, semaphore: Int? = nil) {
        self.value = value
//        if let semaphore {
////            self.semaphore = .init(value: semaphore)
//        }
    }

    init<K>(semaphore: Int? = nil) where T == K? {
        value = nil
//        if let semaphore {
////            self.semaphore = .init(value: semaphore)
//        }
    }

    func bind(
        inQueue queue: DispatchQueue? = nil,
        semaphoreSignal: Bool = true,
        listener: @escaping Listener
    ) {
        let boxListener = BoxListener(
            listener: listener,
            queue: queue,
            semaphoreSignal: semaphoreSignal
        )
        self.boxListener = boxListener

        guard let queue = boxListener.queue else {
            boxListener.listener(value)
            return
        }

        queue.async { [weak self] in
            guard let self else { return }
            boxListener.listener(value)
        }
    }
}
