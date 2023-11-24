//
//  RoundButton.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/11/24.
//

import UIKit

class RoundButton: UIButton {
    var roundButtonConfiguration = RoundButtonConfiguration(
        onBackgroundColor: .accent,
        onTintColor: .fsPrimary,
        offBackgroundColor: .fsPrimary,
        offTintColor: .fsBg
    ) {
        didSet {
            isOn ? setupOnState() : setupOffState()
        }
    }

    var onImage: UIImage? {
        didSet {
            isOn ? setupOnState() : setupOffState()
        }
    }

    var offImage: UIImage? {
        didSet {
            isOn ? setupOnState() : setupOffState()
        }
    }

    var isOn = true {
        didSet {
            isOn ? setupOnState() : setupOffState()
        }
    }

    var onHandler: (() -> Void)?
    var offHandler: (() -> Void)?

    func setupToggle() {
        addAction { [weak self] in
            guard let self else { return }
            isOn.toggle()
            if isOn {
                onHandler?()
            } else {
                offHandler?()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.height, bounds.width) / 2
    }

    private func setupOnState() {
        backgroundColor = roundButtonConfiguration.onBackgroundColor
        tintColor = roundButtonConfiguration.onTintColor
        setImage(onImage, for: .normal)
    }

    private func setupOffState() {
        backgroundColor = roundButtonConfiguration.offBackgroundColor
        tintColor = roundButtonConfiguration.offTintColor
        setImage(offImage, for: .normal)
    }
}

struct RoundButtonConfiguration {
    var onBackgroundColor: UIColor
    var onTintColor: UIColor
    var offBackgroundColor: UIColor
    var offTintColor: UIColor
}
