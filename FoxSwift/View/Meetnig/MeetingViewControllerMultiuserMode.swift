//
//  MeetingViewControllerMultiuserMode.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/23.
//

import UIKit

extension MeetingViewController {
    func setupMultiuserView() {
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .fsBg

        collectionView.collectionViewLayout = setupCollectionViewLayout()

        collectionView.pinTo(view, safeArea: true)

        collectionView.registReuseCell(for: UICollectionViewCell.self)

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / 2),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.contentInsets = .init(top: 20, leading: 40, bottom: 0, trailing: 40)

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

extension MeetingViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        videoViews.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.getReuseCell(
            for: UICollectionViewCell.self,
            indexPath: indexPath
        ) else { fatalError("No such cell") }

        let videoView = videoViews[indexPath.row]
        if videoView.superview !== cell.contentView {
            videoView.removeFromSuperview()
            videoView.removeConstraints(videoView.constraints)
            videoView.addTo(cell.contentView) { make in
                make.center.equalTo(cell.contentView)
                make.height.width.equalTo(150)
            }
            videoView.layer.cornerRadius = 30
            videoView.backgroundColor = .fsPrimary
        }

        return cell
    }
}

extension MeetingViewController: UICollectionViewDelegate {}
