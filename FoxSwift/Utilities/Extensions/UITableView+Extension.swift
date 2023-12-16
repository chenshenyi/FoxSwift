import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UITableView {
    func registReuseCell<T: UITableViewCell>(for cellType: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func getReuseCell<T: UITableViewCell>(for cellType: T.Type, indexPath: IndexPath) -> T? {
        dequeueReusableCell(
            withIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T
    }
}

extension UITableView {
    func registReuseHeaderFooterView<T: UITableViewHeaderFooterView>(for viewType: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func getReuseHeaderFooterView<T: UITableViewHeaderFooterView>(for viewType: T.Type) -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
    }
}
