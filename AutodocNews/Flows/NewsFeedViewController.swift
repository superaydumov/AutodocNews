//
//  ViewController.swift
//  NewsFeedTestApp
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit
import Combine

final class NewsFeedViewController: UIViewController {

    // MARK: - Stored properties

    private let viewModel = NewsFeedViewModel()
    private var cancellables = Set<AnyCancellable>()

    private enum Section {
        case main
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsFeedItem>?
    private let cellHeight: CGFloat = 180
    private let triggerAmountLimit = 5

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

        return collectionView
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
        title = "Новости"

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
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let markerItem = viewModel.items.count - triggerAmountLimit
        if indexPath.item >= markerItem {
            viewModel.loadNextPageIfNeeded()
        }
    }
}

    // MARK: - Private methods

private extension NewsFeedViewController {

    func setupSubViews() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.cellHeight)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(self.cellHeight)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: AppSpacing.small,
                leading: AppSpacing.medium,
                bottom: AppSpacing.small,
                trailing: AppSpacing.medium
            )
            section.interGroupSpacing = AppSpacing.small

            return section
        }
    }

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
            .receive(on: RunLoop.main)
            .sink { [weak self] loading in
                guard let self else { return }
                if !loading {
                    self.refreshControl.endRefreshing()
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

    func refreshData() {
        refreshControl.endRefreshing()
        viewModel.loadFirstPage()
    }
}
