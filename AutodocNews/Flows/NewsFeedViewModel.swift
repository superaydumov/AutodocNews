//
//  NewsFeedViewModel.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import Foundation

final class NewsFeedViewModel {

    var items = [NewsFeedItem]()
    var isLoading: Bool = false
    var errorMessage: String?

    private let networkService = NetworkService.shared
    private let pageSize: Int = 15
    private var currentPage: Int = 1
    private var totalCount = Int.max

    private var canLoadNextPage: Bool {
        items.count < totalCount
    }

    func loadFirstPage() async {
        currentPage = 1
        items.removeAll()
        await loadNextPageIfNeeded()
    }

    func loadNextPageIfNeeded() async {
        guard !isLoading, canLoadNextPage else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await networkService.fetchNewsFeed(
                page: currentPage,
                pageSize: pageSize
            )

            totalCount = response.totalCount
            items.append(contentsOf: response.news)
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
