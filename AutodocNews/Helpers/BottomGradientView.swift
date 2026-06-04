//
//  BottomGradientView.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import UIKit

final class BottomGradientView: UIView {

    private let gradientLayer = CAGradientLayer()

    init(
        startAlpha: CGFloat,
        endAlpha: CGFloat
    ) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        layer.insertSublayer(gradientLayer, at: 0)

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(startAlpha).cgColor,
            UIColor.black.withAlphaComponent(endAlpha).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
