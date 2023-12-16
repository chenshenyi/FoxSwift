import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}


extension UICollectionView {
    func registReuseCell<T: UICollectionViewCell>(for cellType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func getReuseCell<T: UICollectionViewCell>(for cellType: T.Type, indexPath: IndexPath) -> T? {
        dequeueReusableCell(
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T
    }
}

extension UICollectionView {
    func registReuseHeader<T: UICollectionReusableView>(for viewType: T.Type) {
        register(
            T.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func getReuseHeader<T: UICollectionReusableView>(
        for viewType: T.Type,
        indexPath: IndexPath
    ) -> T? {
        dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T
    }

    func registReuseFooter<T: UICollectionReusableView>(for viewType: T.Type) {
        register(
            T.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func getReuseFooter<T: UICollectionReusableView>(
        for viewType: T.Type,
        indexPath: IndexPath
    ) -> T? {
        dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T
    }
}
