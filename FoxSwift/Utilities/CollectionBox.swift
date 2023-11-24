//
//  CollectionBox.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/23.
//

import Foundation

final class DiffBox<T: Hashable> {
    typealias Listener = ([Diff: [T]]) -> Void
    var listener: Listener?

    enum Diff {
        case added
        case deleted
        case unchanged
    }

    var value: [T] {
        didSet {
            let oldSet = Set(oldValue)
            let newSet = Set(value)

            let adds = Array(newSet.subtracting(oldSet))
            let deletes = Array(oldSet.subtracting(newSet))
            let unchanges = Array(newSet.intersection(oldSet))

            var diffs: [Diff: [T]] = [:]
            diffs[.added] = adds.isEmpty ? nil : adds
            diffs[.deleted] = deletes.isEmpty ? nil : deletes
            diffs[.unchanged] = unchanges.isEmpty ? nil : unchanges

            listener?(diffs)
        }
    }

    init(_ value: [T]) {
        self.value = value
    }

    func bind(listener: Listener?) {
        self.listener = listener
        listener?([.added: value])
    }
}
