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
        title = "Новости"

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

        let textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        textView.textAlignment = .center
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let viewModel = NewsFeedViewModel()

        Task {
            await viewModel.loadFirstPage()
            print(viewModel.items)
            textView.text = viewModel.items[4].title

            let item = viewModel.items[4]
            let loadedImage = try await ImageLoader.shared.loadImage(
                urlString: item.titleImageUrl ?? "no image url"
            )
            imageView.image = loadedImage
        }
    }
}
