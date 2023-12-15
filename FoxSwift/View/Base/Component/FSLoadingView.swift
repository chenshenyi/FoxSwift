//
//  FSLoadingView.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/13.
//

import UIKit

class FSLoadingView: UIView {
    let label = UILabel()
    let imageView = UIImageView(image: .foxWithBubble)

    init(text: String = "") {
        super.init(frame: .zero)

        backgroundColor = .fsBg
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.fsPrimary.cgColor

        label.text = text
        label.textColor = .fsText

        setupConstraint()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup Subview
    func setupConstraint() {
        label.addTo(self) { make in
            make.centerX.bottom.equalToSuperview().inset(10)
        }

        imageView.addTo(self) { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(100)
        }
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        imageView.layer.add(rotation, forKey: "rotationAnimation")

        let changeColor = CAKeyframeAnimation(keyPath: "backgroundColor")
        changeColor.values = [
            UIColor.fsBg.cgColor,
            UIColor.fsPrimary.cgColor,
            UIColor.fsBg.cgColor
        ]
        changeColor.duration = 1
        changeColor.keyTimes = [0, 0.5, 1]
        changeColor.repeatCount = .greatestFiniteMagnitude
        layer.add(changeColor, forKey: "backgroundColor")
    }
}
