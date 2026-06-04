//
//  ViewController.swift
//  NewsFeedTestApp
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit
import Combine
import SafariServices

final class NewsFeedViewController: UIViewController {

    // MARK: - Stored properties

    private let viewModel = NewsFeedViewModel()
    private var cancellables = Set<AnyCancellable>()

    private enum Section {
        case main
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsFeedItem>?
    private weak var footerLoaderView: NewsFooterLoaderView?
    private let cellHeight: CGFloat = 180
    private let footerHeight: CGFloat = 48
    private let widthParameter: CGFloat = 900

    // MARK: - Computed properties

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl

        collectionView.register(
            NewsCell.self,
            forCellWithReuseIdentifier: NewsCell.reuseIdentifier
        )

        collectionView.register(
            NewsFooterLoaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: NewsFooterLoaderView.reuseIdentifier
        )

        return collectionView
    }()

    private lazy var activityIndicator: LoaderView = {
        let loader = LoaderView()
        loader.isHidden = true

        return loader
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.refreshData()
            },
            for: .valueChanged
        )

        return refreshControl
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Новости Autodoc"

        setupSubViews()
        setupDataSource()
        setupBindings()

        viewModel.loadFirstPage()
    }
}

    // MARK: - UICollectionViewDelegate

extension NewsFeedViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard elementKind == UICollectionView.elementKindSectionFooter,
              let footer = view as? NewsFooterLoaderView else { return }
        footer.startAnimating()
        viewModel.loadNextPageIfNeeded()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource?.itemIdentifier(for: indexPath),
              let url = URL(string: item.fullUrl) else { return }

        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}

    // MARK: - Private methods

private extension NewsFeedViewController {

    // MARK: Layout methods

    func setupSubViews() {
        [collectionView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
            guard let self else { return nil }

            let width = environment.container.effectiveContentSize.width
            let columns: Int

            switch environment.traitCollection.horizontalSizeClass {
            case .compact:
                columns = 1
            case .regular:
                columns = width >= widthParameter ? 3 : 2
            default:
                columns = 1
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .absolute(self.cellHeight)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.cellHeight)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(AppSpacing.small)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: AppSpacing.small,
                leading: AppSpacing.medium,
                bottom: AppSpacing.small,
                trailing: AppSpacing.medium
            )
            section.interGroupSpacing = AppSpacing.small

            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.footerHeight)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]

            return section
        }
    }

    // MARK: Data handling methods

    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsCell.reuseIdentifier,
                for: indexPath
            ) as? NewsCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)

            return cell
        }

        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self, kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NewsFooterLoaderView.reuseIdentifier,
                for: indexPath
            ) as? NewsFooterLoaderView
            self.footerLoaderView = footer

            return footer
        }
    }

    func setupBindings() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.applySnapshot(items)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .combineLatest(viewModel.$items)
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading, items in
                guard let self else { return }
                if isLoading && items.isEmpty {
                    self.activityIndicator.startAnimating()
                    self.collectionView.isHidden = true
                } else {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.isHidden = false
                    if !isLoading {
                        self.refreshControl.endRefreshing()
                    }
                }

                if !isLoading {
                    self.footerLoaderView?.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] errorMessage in
                guard let self else { return }
                self.showError(errorMessage)
            }
            .store(in: &cancellables)
    }

    func applySnapshot(_ items: [NewsFeedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, NewsFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    func refreshData() {
        refreshControl.endRefreshing()
        viewModel.loadFirstPage()
    }

    // MARK: Error handling

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Повторить",
                style: .default
            ) { [weak self] _ in
                guard let self else { return }
                self.refreshData()
            }
        )

        alert.addAction(
            UIAlertAction(
                title: "Отмена",
                style: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                self.refreshControl.endRefreshing()
            }
        )

        present(alert, animated: true)
    }
}
