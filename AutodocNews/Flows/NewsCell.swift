//
//  NewsCell.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit

final class NewsCell: UICollectionViewCell {

    static let reuseIdentifier = "NewsCell"

    private lazy var paddingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemMint

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 2

        return label
    }()

    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel

        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(with item: NewsFeedItem) {
        titleLabel.text = item.title
        categoryLabel.text = item.categoryType
        dateLabel.text = item.publishedDate
    }

}

private extension NewsCell {

    func setupSubViews() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        [
            paddingImageView,
            categoryLabel,
            titleLabel,
            dateLabel
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            paddingImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paddingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            paddingImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            paddingImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            categoryLabel.topAnchor.constraint(equalTo: paddingImageView.topAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: paddingImageView.leadingAnchor, constant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
