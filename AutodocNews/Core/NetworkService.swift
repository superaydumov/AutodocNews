//
//  NetworkService.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import Foundation

actor NetworkService {
    static let shared = NetworkService()
    private init() { }

    private let baseURL = "https://webapi.autodoc.ru/api/news"

    func fetchNewsFeed(
        page: Int,
        pageSize: Int
    ) async throws -> NewsFeedResponse {
        guard let url = URL(string: "\(baseURL)/\(page)/\(pageSize)") else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(NewsFeedResponse.self, from: data)
    }
}
