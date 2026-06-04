//
//  NewsFeedViewModel.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import Foundation

@MainActor
final class NewsFeedViewModel: ObservableObject {

    @Published var items = [NewsFeedItem]()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let networkService = NetworkService.shared
    private let pageSize: Int = 15
    private var currentPage: Int = 1
    private var totalCount = Int.max
    private var loadingTask: Task<Void, Never>?

    private var canLoadNextPage: Bool {
        items.count < totalCount
    }

    func loadFirstPage() {
        currentPage = 1
        items.removeAll()
        loadNextPageIfNeeded()
    }

    func loadNextPageIfNeeded() {
        guard !isLoading, canLoadNextPage else { return }

        loadingTask = Task {
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

    deinit {
        loadingTask?.cancel()
    }
}
