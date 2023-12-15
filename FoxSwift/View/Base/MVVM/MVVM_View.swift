//
//  MVVM_View.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import Foundation

protocol MVVMView<ViewModel>: AnyObject {
    associatedtype ViewModel

    var viewModel: ViewModel? { get set }

    func setupViewModel(viewModel: ViewModel)
}
