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

    private let viewModel: NewsFeedViewModel
    private var cancellables = Set<AnyCancellable>()

    private enum Section {
        case main
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsFeedItem>?
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

    // MARK: - Initialisers

    init(viewModel: NewsFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

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
            section.contentInsetsReference = .none
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

        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NewsFooterLoaderView.reuseIdentifier,
                for: indexPath
            ) as? NewsFooterLoaderView
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

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .loadingFirstPage:
                    activityIndicator.startAnimating()
                    collectionView.isHidden = true
                case .loadingNextPage:
                    break
                case .idle:
                    activityIndicator.stopAnimating()
                    collectionView.isHidden = false
                    refreshControl.endRefreshing()
                    currentFooterView()?.stopAnimating()
                case .error(let message):
                    activityIndicator.stopAnimating()
                    collectionView.isHidden = false
                    refreshControl.endRefreshing()
                    currentFooterView()?.stopAnimating()
                    viewModel.showError(message) { [weak self] in
                        guard let self else { return }
                        self.refreshData()
                    }
                }
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
        viewModel.loadFirstPage()
    }

    func currentFooterView() -> NewsFooterLoaderView? {
        collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: IndexPath(item: 0, section: 0)
        ) as? NewsFooterLoaderView
    }
}
