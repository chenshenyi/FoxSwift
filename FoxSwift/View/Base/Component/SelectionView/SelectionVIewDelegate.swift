//
//  SelectionVIewDelegate.swift
//  DV1
//
//  Created by chen shen yi on 2023/10/31.
//

import UIKit

/// Methods for managing selecting actions for a `SelectionView`
protocol SelectionViewDelegate: AnyObject {
    func selectionShouldSelect(_ selectionView: SelectionView, forIndex index: Int) -> Bool

    func selectionDidSelect(_ selectionView: SelectionView, forIndex index: Int)
}

extension SelectionViewDelegate {
    func selectionShouldSelect(_ selectionView: SelectionView, forIndex index: Int) -> Bool { true }

    func selectionDidSelect(_ selectionView: SelectionView, forIndex index: Int) {}
}
