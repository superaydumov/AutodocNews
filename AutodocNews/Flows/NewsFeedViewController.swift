//
//  ViewController.swift
//  NewsFeedTestApp
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit

final class NewsFeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "News Feed Test App"

        Task {
            let response = try await NetworkService.shared.fetchNewsFeed(page: 1, pageSize: 5)
            print(response.news)
        }
    }
}
