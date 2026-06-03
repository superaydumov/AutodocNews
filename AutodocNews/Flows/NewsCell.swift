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
        imageView.backgroundColor = .lightGray

        return imageView
    }()

    private lazy var categoryPaddingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10

        return view
    }()

    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.75)

        return label
    }()

    private lazy var bottomGradientView = BottomGradientView(
        startAlpha: 0.0,
        endAlpha: 0.45
    )

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .white

        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.75)

        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        categoryLabel.text = nil
        dateLabel.text = nil
    }

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
            bottomGradientView,
            categoryPaddingView,
            bottomStack
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        categoryPaddingView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            paddingImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paddingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            paddingImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            paddingImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            bottomGradientView.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            categoryPaddingView.topAnchor.constraint(equalTo: paddingImageView.topAnchor, constant: 8),
            categoryPaddingView.leadingAnchor.constraint(equalTo: paddingImageView.leadingAnchor, constant: 8),
            categoryPaddingView.heightAnchor.constraint(equalToConstant: 20),

            categoryLabel.topAnchor.constraint(equalTo: categoryPaddingView.topAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryPaddingView.leadingAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryPaddingView.trailingAnchor, constant: -8),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryPaddingView.bottomAnchor, constant: -4),

            bottomStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bottomStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            bottomStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
