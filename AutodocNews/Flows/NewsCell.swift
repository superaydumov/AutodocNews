//
//  NewsCell.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit

final class NewsCell: UICollectionViewCell {

    // MARK: - Stored properties

    static let reuseIdentifier = "NewsCell"
    private let categoryPaddingHeight: CGFloat = 24
    private var imageLoadTask: Task<Void, Never>?
    private let dateFormatter = DateFormatter()

    // MARK: - Computed properties

    private lazy var shimmerPlaceholderView = ShimmerPlaceholderView()

    private lazy var paddingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .lightGray

        return imageView
    }()

    private lazy var categoryPaddingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12

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
        stack.spacing = AppSpacing.small
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

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        shimmerPlaceholderView.stopAnimating()
        isUserInteractionEnabled = true
        paddingImageView.alpha = 1
        paddingImageView.image = nil
        titleLabel.text = nil
        categoryLabel.text = nil
        dateLabel.text = nil
    }

    // MARK: - Initialisers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Public API

    func configure(with item: NewsFeedItem) {
        titleLabel.text = item.title
        categoryLabel.text = item.categoryType
        dateLabel.text = dateFormatter.formatDate(item.publishedDate)

        imageLoadTask?.cancel()
        paddingImageView.alpha = 0
        paddingImageView.image = nil
        shimmerPlaceholderView.startAnimating()
        isUserInteractionEnabled = false

        guard let imageUrlString = item.titleImageUrl else {
            shimmerPlaceholderView.stopAnimating()
            isUserInteractionEnabled = true
            paddingImageView.image = UIImage(systemName: "photo")
            paddingImageView.contentMode = .scaleAspectFit
            paddingImageView.tintColor = .white.withAlphaComponent(0.75)
            paddingImageView.alpha = 1
            return
        }

        imageLoadTask = Task { [weak self] in
            guard let self else { return }
            let image = try? await ImageLoader.shared.loadImage(urlString: imageUrlString)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.paddingImageView.image = image
                self.paddingImageView.contentMode = .scaleAspectFill
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                    self.shimmerPlaceholderView.alpha = 0
                    self.paddingImageView.alpha = 1
                } completion: { _ in
                    self.shimmerPlaceholderView.stopAnimating()
                    self.shimmerPlaceholderView.alpha = 1
                    self.isUserInteractionEnabled = true
                }
            }
        }
    }
}

    // MARK: - Private methods

private extension NewsCell {

    func setupSubViews() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        [
            paddingImageView,
            bottomGradientView,
            categoryPaddingView,
            bottomStack,
            shimmerPlaceholderView
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        categoryPaddingView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            paddingImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paddingImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            paddingImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            paddingImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            bottomGradientView.topAnchor.constraint(equalTo: contentView.centerYAnchor),
            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            categoryPaddingView.topAnchor.constraint(
                equalTo: paddingImageView.topAnchor,
                constant: AppSpacing.small
            ),
            categoryPaddingView.leadingAnchor.constraint(
                equalTo: paddingImageView.leadingAnchor,
                constant: AppSpacing.small
            ),
            categoryPaddingView.heightAnchor.constraint(equalToConstant: categoryPaddingHeight),

            categoryLabel.topAnchor.constraint(
                equalTo: categoryPaddingView.topAnchor,
                constant: AppSpacing.extraSmall
            ),
            categoryLabel.leadingAnchor.constraint(
                equalTo: categoryPaddingView.leadingAnchor,
                constant: AppSpacing.small
            ),
            categoryLabel.trailingAnchor.constraint(
                equalTo: categoryPaddingView.trailingAnchor,
                constant: -AppSpacing.small
            ),
            categoryLabel.bottomAnchor.constraint(
                equalTo: categoryPaddingView.bottomAnchor,
                constant: -AppSpacing.extraSmall
            ),

            bottomStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: AppSpacing.small
            ),
            bottomStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -AppSpacing.small
            ),
            bottomStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -AppSpacing.small
            ),

            shimmerPlaceholderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shimmerPlaceholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shimmerPlaceholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shimmerPlaceholderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
