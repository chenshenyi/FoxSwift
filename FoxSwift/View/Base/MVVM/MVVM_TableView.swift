//
//  TableDataSourceVM.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/15.
//

import UIKit

protocol TableDataSourceViewModel: MVVMViewModel {
    func numberOfRows(for section: Int) -> Int

    func cellViewModel(for indexPath: IndexPath) -> MVVMViewModel
}

protocol MVVMTableCell: UITableViewCell, MVVMView {}

extension MVVMView {
    func tableViewCell<Cell: MVVMTableCell>(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> Cell where ViewModel == any TableDataSourceViewModel {
        guard let cell = tableView.getReuseCell(for: Cell.self, indexPath: indexPath)
        else { fatalError("\(Cell.reuseIdentifier) not regist.") }

        if let cellViewModel = viewModel?.cellViewModel(for: indexPath) as? Cell.ViewModel {
            cell.setupViewModel(viewModel: cellViewModel)
        }

        return cell
    }
}
