//
//  ImageLoader.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func loadImage(urlString: String) async throws -> UIImage {
        let urlKey = urlString as NSString
        if let cachedImage = cache.object(forKey: urlKey) {
            return cachedImage
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        cache.setObject(image, forKey: urlKey)

        return image
    }
}
