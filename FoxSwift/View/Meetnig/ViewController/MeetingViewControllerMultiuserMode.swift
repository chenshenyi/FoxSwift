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

        defaultLayout(1)

        videoCollectionView.addTo(view) { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide).inset(5)
            make.bottom.equalTo(videoControlBar.snp.top).offset(-20)
        }

        videoCollectionView.registReuseCell(for: UICollectionViewCell.self)
    }

    func defaultLayout(_ columnAmount: Int) {
        let columnAmount = CGFloat(columnAmount)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / columnAmount),
            heightDimension: .fractionalWidth(1 / columnAmount)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / columnAmount)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        videoCollectionView.alwaysBounceVertical = true
        videoCollectionView.collectionViewLayout = layout
    }

    func topRowLayout(_ amount: Int) {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / CGFloat(amount)),
            heightDimension: .fractionalWidth(1 / CGFloat(amount))
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(CGFloat(amount) / 2),
            heightDimension: .fractionalWidth(1 / 2)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        videoCollectionView.alwaysBounceVertical = false
        videoCollectionView.collectionViewLayout = layout
        videoCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .right, animated: false)
    }
}

extension MeetingViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        (viewModel?.participants.value.count ?? 0) + (viewModel?.sharer.value == nil ? 0 : 1)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.getReuseCell(
            for: UICollectionViewCell.self,
            indexPath: indexPath
        ) else { fatalError("No such cell") }

        let index = indexPath.row - (viewModel?.sharer.value == nil ? 0 : 1)

        if index >= 0 {
            guard let participant = viewModel?.participants.value[index] else {
                fatalError("no participant")
            }

            let videoView = VideoView(participant: participant)
            videoView.addTo(cell.contentView) { make in
                make.center.size.equalTo(cell.contentView).inset(8)
            }

            if participant.id != Participant.currentUser.id ||
                viewModel?.isOnCamera.value == true {
            
                viewModel?.fetchVideo(into: videoView, for: participant)
            }

            videoView.showNameLabel()
        } else {
            guard let participant = viewModel?.sharer.value else {
                fatalError("no participant")
            }

            let videoView = VideoView(participant: participant)
            videoView.addTo(cell.contentView) { make in
                make.center.size.equalTo(cell.contentView).inset(8)
            }

            viewModel?.fetchScreenSharing(into: videoView, for: participant)

            videoView.showNameLabel()
        }

        return cell
    }
}

extension MeetingViewController: UICollectionViewDelegate {}
