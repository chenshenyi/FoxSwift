//
//  FSPopup.swift
//  FoxSwift
//
//  Created by chen shen yi on 2023/12/13.
//

import UIKit

class FSPopup: UIView {
    enum Style {
        case checkmark
        case error
    }

    var style: Style = .checkmark
    var label = UILabel()
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    init(text: String, style: Style) {
        super.init(frame: .zero)

        self.style = style

        blurView.alpha = 0.9

        backgroundColor = .clear
        layer.cornerRadius = 30
        clipsToBounds = true

        setupLabel(text: text)

        setupConstraint()
    }

    func setupLabel(text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.fsText,
            NSAttributedString.Key.foregroundColor: UIColor.accent,
            NSAttributedString.Key.strokeWidth: -1.0
        ]

        // Create the text with a stroke as an attributed string
        let textWithStroke = NSAttributedString(
            string: text,
            attributes: attributes
        )

        label.attributedText = textWithStroke
        label.font = .config(weight: .medium, size: 18)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraint() {
        blurView.addTo(self) { make in
            make.edges.equalToSuperview()
        }

        label.addTo(self) { make in
            make.horizontalEdges.bottom.equalToSuperview().inset(10)
        }

        snp.makeConstraints { make in
            make.size.equalTo(140)
        }
    }

    func checkAnimation() {
        let path = UIBezierPath()

        let left = 30
        let midX = 60
        let midY = 90
        let right = 50

        path.move(to: CGPoint(x: midX - left, y: midY - left))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: midX + right, y: midY - right))

        // create shape layer for that path
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.accent.cgColor
        shapeLayer.lineWidth = 8
        shapeLayer.path = path.cgPath
        shapeLayer.style = ["lineCap": CAShapeLayerLineCap.round]

        // animate it
        layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.4
        shapeLayer.add(animation, forKey: "MyAnimation")
    }

    func errorAnimation() {
        let len = 30
        let midX = 70
        let midY = 65

        let path = UIBezierPath()
        path.move(to: CGPoint(x: midX - len, y: midY - len))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: midX + len, y: midY + len))

        path.move(to: CGPoint(x: midX + len, y: midY - len))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: midX - len, y: midY + len))

        // create shape layer for that path
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.accent.cgColor
        shapeLayer.lineWidth = 8
        shapeLayer.path = path.cgPath
        shapeLayer.style = ["lineCap": CAShapeLayerLineCap.round]

        // animate it
        layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.4
        shapeLayer.add(animation, forKey: "MyAnimation")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        switch style {
        case .checkmark: checkAnimation()
        case .error: errorAnimation()
        }
    }
}
