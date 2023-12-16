//
//  MVVMTableDataSourceViewModel.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

protocol MVVMTableDataSourceViewModel: MVVMViewModel {
    func numberOfRows(for section: Int) -> Int

    func cellViewModel(for indexPath: IndexPath) -> MVVMViewModel
}
