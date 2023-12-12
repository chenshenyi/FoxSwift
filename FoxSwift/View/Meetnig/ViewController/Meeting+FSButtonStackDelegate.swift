//
//  Meeting+FSButtonStackDelegate.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/12.
//

import UIKit

extension MeetingViewController: FSButtonStackDelegate {
    enum ButtonKey: CaseIterable, Hashable {
        case hangUp
        case mic
        case camera
        case message
        case shareScreen
    }

    var isOnCamera: Bool {
        viewModel?.isOnCamera.value ?? false
    }

    var isOnMic: Bool {
        viewModel?.isOnMic.value ?? false
    }

    var isSharingScreen: Bool {
        viewModel?.isSharingScreen.value ?? false
    }

    func buttonDidTapped(_ buttonStack: ButtonStack, for key: ButtonKey) {
        guard let viewModel else { return }

        switch key {
        case .hangUp:
            viewModel.leaveMeet()
            dismiss(animated: true)
            
        case .mic:
            isOnMic ? viewModel.turnOffMic() : viewModel.turnOnMic()

        case .camera:
            isOnCamera ? viewModel.turnOffCamera() : viewModel.turnOnCamera()

        case .message:
            messageView.isHidden = false

        case .shareScreen:
            isSharingScreen ? viewModel.stopScreenSharing() : viewModel.startScreenSharing()
        }
    }

    func image(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIImage? {
        let systemName = switch key {
        case .hangUp:
            "phone.fill"

        case .mic:
            isOnCamera ? "mic.fill" : "mic.slash.fill"

        case .camera:
            isOnMic ? "video.fill" : "video.slash.fill"

        case .message:
            "message.fill"

        case .shareScreen:
            "rectangle.inset.filled.and.person.filled"
        }

        return UIImage(systemName: systemName)
    }

    func tintColor(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIColor {
        return switch key {
        case .mic:
            isOnMic ? .accent : .fsText

        case .camera:
            isOnCamera ? .accent : .fsText

        case .hangUp, .message:
            .fsText

        case .shareScreen:
            isSharingScreen ? .accent : .fsText
        }
    }

    func backgroundColor(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIColor {
        return switch key {
        case .hangUp:
            .red

        default:
            .fsPrimary
        }
    }

    func size(_ buttonStack: ButtonStack, for key: ButtonKey) -> CGFloat {
        return switch key {
        case .hangUp:
            60

        default:
            45
        }
    }

    func cornerStyle(_ buttonStack: ButtonStack, for key: ButtonKey) -> UIView.CornerStyle {
        .rounded
    }
}
