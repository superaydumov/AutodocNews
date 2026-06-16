//
//  NewsFeedCoordinator.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 16.06.2026.
//

import UIKit

protocol NewsFeedCoordinatorProtocol: AnyObject {
    func showError(_ message: String, retryAction: @escaping () -> Void, cancelAction: @escaping () -> Void)
}

final class NewsFeedCoordinator: NewsFeedCoordinatorProtocol {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor
    func start() {
        let viewModel = NewsFeedViewModel(coordinator: self)
        let viewController = NewsFeedViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showError(
        _ message: String,
        retryAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            retryAction()
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive) { _ in
            cancelAction()
        })

        navigationController.present(alert, animated: true)
    }
}
