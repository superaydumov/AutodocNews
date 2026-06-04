//
//  LoaderView.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import UIKit

final class LoaderView: UIView {

    // MARK: - Stored properties

    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Public API

    func startAnimating() {
        isHidden = false
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }

    // MARK: - Private methods

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black.withAlphaComponent(0.35)
        layer.cornerRadius = 12
        clipsToBounds = true
        isUserInteractionEnabled = false
        isHidden = true

        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .white

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: activityIndicatorView.widthAnchor, constant: 16),
            heightAnchor.constraint(equalTo: activityIndicatorView.heightAnchor, constant: 16),
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
