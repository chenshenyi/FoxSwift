//
//  VideoControlBar.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/24.
//

import UIKit

class VideoControlBar: UIView {
    let micButton = RoundButton()
    let muteButton = RoundButton()
    let cameraButton = RoundButton()

    convenience init() {
        self.init(frame: .zero)

        setupButtons()
    }

    func setupButtons() {
        let config = RoundButtonConfiguration(
            onBackgroundColor: .fsPrimary,
            onTintColor: .accent,
            offBackgroundColor: .fsPrimary,
            offTintColor: .fsText
        )

        muteButton.roundButtonConfiguration = config
        muteButton.onImage = .init(systemName: "volume.fill")
        muteButton.offImage = .init(systemName: "volume.slash.fill")
        muteButton.setupToggle()
        muteButton.addTo(self) { make in
            make.centerY.equalTo(self)
            make.height.width.equalTo(45)
            make.leading.equalTo(self).inset(30)
        }

        micButton.roundButtonConfiguration = config
        micButton.onImage = .init(systemName: "mic.fill")
        micButton.offImage = .init(systemName: "mic.slash.fill")
        micButton.setupToggle()
        micButton.addTo(self) { make in
            make.centerY.equalTo(self)
            make.height.width.equalTo(45)
            make.centerX.equalTo(self)
        }

        cameraButton.roundButtonConfiguration = config
        cameraButton.setupToggle()
        cameraButton.onImage = .init(systemName: "video.fill")
        cameraButton.offImage = .init(systemName: "video.slash.fill")
        cameraButton.addTo(self) { make in
            make.centerY.equalTo(self)
            make.height.width.equalTo(45)
            make.trailing.equalTo(self).inset(30)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }
}
