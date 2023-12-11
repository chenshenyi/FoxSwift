//
//  SelectionViewDataSource.swift
//  DV1
//
//  Created by chen shen yi on 2023/10/31.
//

import UIKit

/// The methods that an object adopts to manage data, provide title,
/// and change display setting for a `SelectionView`
protocol SelectionViewDataSource: AnyObject {
    func numberOfSelections(_ selectionView: SelectionView) -> Int

    func title(_ selectionView: SelectionView, forIndex index: Int) -> String

    func textColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor

    func font(_ selectionView: SelectionView, forIndex index: Int) -> UIFont

    func indicatorColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor
}

extension SelectionViewDataSource {
    func numberOfSelections(_ selectionView: SelectionView) -> Int {
        2
    }

    func textColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        .white
    }

    func font(_ selectionView: SelectionView, forIndex index: Int) -> UIFont {
        .systemFont(ofSize: 18)
    }

    func indicatorColor(_ selectionView: SelectionView, forIndex index: Int) -> UIColor {
        .blue
    }
}
