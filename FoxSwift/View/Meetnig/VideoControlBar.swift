//
//  VideoControlBar.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/24.
//

import UIKit

extension VideoControlBar {
    private enum Button {
        case mic
        case speaker
        case camera
        case message
        case shareScreen

        var onImage: UIImage? {
            switch self {
            case .mic: return .init(systemName: "mic.fill")
            case .speaker: return .init(systemName: "volume.fill")
            case .camera: return .init(systemName: "video.fill")
            case .message: return .init(systemName: "message.fill")
            case .shareScreen: return .init(systemName: "rectangle.inset.filled.and.person.filled")
            }
        }

        var offImage: UIImage? {
            switch self {
            case .mic: return .init(systemName: "mic.slash.fill")
            case .speaker: return .init(systemName: "volume.slash.fill")
            case .camera: return .init(systemName: "video.slash.fill")
            case .message: return .init(systemName: "message.fill")
            case .shareScreen: return .init(systemName: "rectangle.inset.filled.and.person.filled")
            }
        }
    }
}

class VideoControlBar: UIView {
    let micButton = RoundButton()
    let speakerButton = RoundButton()
    let cameraButton = RoundButton()
    let messageButton = RoundButton()
    let shareScreenButton = RoundButton()

    var buttons: [RoundButton] = []

    var buttonSize = 45.0
    var buttonSpace = 20.0

    convenience init() {
        self.init(frame: .zero)

        setupButtons()
    }

    convenience init(buttonSize: Double, space: Double) {
        self.init(frame: .zero)
        self.buttonSize = buttonSize
        buttonSpace = space
        setupButtons()
    }

    private func setupButtons() {
        let config = RoundButtonConfiguration(
            onBackgroundColor: .fsPrimary,
            onTintColor: .accent,
            offBackgroundColor: .fsPrimary,
            offTintColor: .fsText
        )

        buttons = [Button.mic, .camera, .speaker, .message, .shareScreen].map {
            let button = switch $0 {
            case .mic: micButton
            case .speaker: speakerButton
            case .camera: cameraButton
            case .message: messageButton
            case .shareScreen: shareScreenButton
            }

            switch $0 {
            case .message:
                messageButton.roundButtonConfiguration = .init(
                    onBackgroundColor: .fsPrimary,
                    onTintColor: .fsText,
                    offBackgroundColor: .fsPrimary,
                    offTintColor: .fsText
                )
            default:
                button.roundButtonConfiguration = config
            }
            button.onImage = $0.onImage
            button.offImage = $0.offImage
            button.setupToggle()

            return button
        }

        buttons.enumerated().forEach { index, button in
            let center = Double(buttons.count - 1) / 2
            let spacesFromCenter = Double(index) - center
            let offset = (buttonSpace + buttonSize) * spacesFromCenter

            button.addTo(self) { make in
                make.size.equalTo(buttonSize)
                make.centerY.equalTo(self)
                make.centerX.equalTo(self).offset(offset)
            }
        }
    }
}
