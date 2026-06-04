//
//  ShimmerPlaceholderView.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import UIKit

final class ShimmerPlaceholderView: UIView {

    // MARK: - Stored properties

    private let shimmerString = "shimmer"
    private let locationsString = "locations"

    private let titleHeight: CGFloat = 18
    private let dateHeight: CGFloat = 14
    private let elementWidth: CGFloat = 80
    private let elementHeight: CGFloat = 24

    // MARK: - Computed properties

    private lazy var categoryPill = PlaceholderBlock(cornerRadius: 12)
    private lazy var titleLine1 = PlaceholderBlock(cornerRadius: 6)
    private lazy var titleLine2 = PlaceholderBlock(cornerRadius: 6)
    private lazy var dateLine = PlaceholderBlock(cornerRadius: 6)

    private lazy var shimmerGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [-1, -0.5, 0]

        return gradient
    }()

    // MARK: - Initialisers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPlaceholders()
        shimmerGradient.frame = bounds
    }

    // MARK: - Public API

    func startAnimating() {
        isHidden = false
        guard shimmerGradient.animation(forKey: shimmerString) == nil else { return }
        let animation = CABasicAnimation(keyPath: locationsString)
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        shimmerGradient.add(animation, forKey: shimmerString)
    }

    func stopAnimating() {
        shimmerGradient.removeAllAnimations()
        isHidden = true
    }
}

    // MARK: - Private methods

private extension ShimmerPlaceholderView {

    func setupView() {
        backgroundColor = .systemGray6
        isUserInteractionEnabled = false
        isHidden = true
        [categoryPill, titleLine1, titleLine2, dateLine].forEach { addSubview($0) }
        layer.addSublayer(shimmerGradient)
    }

    func layoutPlaceholders() {
        let width = bounds.width
        let height = bounds.height
        let spacing = AppSpacing.small

        let dateY = height - spacing - dateHeight
        let title2Y = dateY - spacing - titleHeight
        let title1Y = title2Y - AppSpacing.extraSmall - titleHeight

        categoryPill.frame = CGRect(
            x: spacing,
            y: spacing,
            width: elementWidth,
            height: elementHeight
        )

        dateLine.frame = CGRect(
            x: spacing,
            y: dateY,
            width: elementWidth,
            height: dateHeight
        )

        titleLine2.frame = CGRect(
            x: spacing,
            y: title2Y,
            width: width * 0.65 - spacing,
            height: titleHeight
        )

        titleLine1.frame = CGRect(
            x: spacing,
            y: title1Y,
            width: width - spacing * 2,
            height: titleHeight
        )
    }
}

    // MARK: - PlaceholderBlock

private final class PlaceholderBlock: UIView {

    init(cornerRadius: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = .systemGray5
        layer.cornerRadius = cornerRadius
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
