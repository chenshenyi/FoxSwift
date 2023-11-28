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

        videoCollectionView.addTo(view) { make in
            make.size.centerX.centerY.equalTo(view.safeAreaLayoutGuide).inset(5)
        }

        videoCollectionView.registReuseCell(for: UICollectionViewCell.self)
    }

    private func setupCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / 2),
            heightDimension: .fractionalWidth(1 / 2)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)


        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / 2)
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
        videoView.addTo(cell.contentView) { make in
            make.center.size.equalTo(cell.contentView)
        }

        viewModel?.fetchVideo(into: videoView, for: participant)

        return cell
    }
}

extension MeetingViewController: UICollectionViewDelegate {}
