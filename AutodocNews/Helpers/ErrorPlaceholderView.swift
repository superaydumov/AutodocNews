//
//  ErrorPlaceholderView.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 16.06.2026.
//

import UIKit

final class ErrorPlaceholderView: UIView {

    var onRetry: (() -> Void)?

    // MARK: - Subviews

    private lazy var iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .thin)
        let imageView = UIImageView(image: UIImage(systemName: "wifi.slash", withConfiguration: config))
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Что-то пошло не так"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Не удалось загрузить новости.\nПроверьте подключение к интернету\nи попробуйте снова."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Повторить"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32)

        let button = UIButton(configuration: config)
        button.addAction(
            UIAction {[weak self] _ in
                guard let self else { return }
                self.onRetry?()
            },
            for: .touchUpInside
        )

        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel, descriptionLabel, retryButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppSpacing.medium
        stack.setCustomSpacing(AppSpacing.small, after: titleLabel)
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

// MARK: - Private

private extension ErrorPlaceholderView {

    func setup() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -AppSpacing.medium),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }
}
