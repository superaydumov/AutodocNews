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

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])

        Task {
            let response = try await NetworkService.shared.fetchNewsFeed(page: 1, pageSize: 5)

            let loadedImage = try await ImageLoader.shared.loadImage(
                urlString: response.news[0].titleImageUrl
                ?? "no image url"
            )

            print(response.news)
            imageView.image = loadedImage
        }
    }
}
