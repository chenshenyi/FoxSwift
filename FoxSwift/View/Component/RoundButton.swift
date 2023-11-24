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

    var isOn: Bool = true {
        didSet {
            isOn ? setupOnState() : setupOffState()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.height, bounds.width)
    }
    
    private func setupOnState() {
        backgroundColor = roundButtonConfiguration.onBackgroundColor
        tintColor = roundButtonConfiguration.onTintColor
    }
    
    private func setupOffState() {
        backgroundColor = roundButtonConfiguration.offBackgroundColor
        tintColor = roundButtonConfiguration.offTintColor
    }
}

struct RoundButtonConfiguration {
    var onBackgroundColor: UIColor
    var onTintColor: UIColor
    var offBackgroundColor: UIColor
    var offTintColor: UIColor
}
