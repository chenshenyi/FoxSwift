//
//  MeetingViewControllerMultiuserMode.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/23.
//

import UIKit

extension MeetingViewController {
    func setupCollectionView() {
        videoCollectionView.dataSource = self
        videoCollectionView.delegate = self
        videoCollectionView.backgroundColor = .fsBg
        videoCollectionView.collectionViewLayout = setupCollectionViewLayout()

        videoCollectionView.pinTo(view, safeArea: true)

        videoCollectionView.registReuseCell(for: UICollectionViewCell.self)
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
        viewModel?.participants.value.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.getReuseCell(
            for: UICollectionViewCell.self,
            indexPath: indexPath
        ) else { fatalError("No such cell") }

        guard let participant = viewModel?.participants.value[indexPath.row] else {
            fatalError("no participant")
        }

        let videoView = VideoView(participant: participant)
        let size = view.frame.width / 2
        videoView.addTo(cell.contentView) { make in
            make.center.equalTo(cell.contentView)
            make.size.equalTo(size)
        }
        videoView.backgroundColor = .fsPrimary

        viewModel?.fetchVideo(into: videoView, for: participant)

        return cell
    }
}

extension MeetingViewController: UICollectionViewDelegate {}
