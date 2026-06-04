//
//  NewsFooterLoaderView.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import UIKit

final class NewsFooterLoaderView: UICollectionReusableView {

    // MARK: - Stored properties

    static let reuseIdentifier = "NewsFooterLoaderView"

    private lazy var activityIndicator: LoaderView = {
        let loader = LoaderView()
        loader.isHidden = true

        return loader
    }()

    // MARK: - Initialisers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Public API

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

// MARK: - Private methods

private extension NewsFooterLoaderView {

    func setup() {
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
