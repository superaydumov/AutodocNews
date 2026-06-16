//
//  NewsFeedViewModel.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import Foundation

enum ViewState: Equatable {
    case idle
    case loadingFirstPage
    case loadingNextPage
    case error(String)

    var isLoading: Bool {
        self == .loadingFirstPage || self == .loadingNextPage
    }
}

@MainActor
final class NewsFeedViewModel: ObservableObject {

    @Published var items = [NewsFeedItem]()
    @Published var state: ViewState = .idle

    private let networkService: NetworkServiceProtocol

    private let pageSize: Int = 15
    private var currentPage: Int = 1
    private var totalCount = Int.max
    private var loadingTask: Task<Void, Never>?

    private var canLoadNextPage: Bool {
        items.count < totalCount
    }

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func loadFirstPage() {
        currentPage = 1
        items.removeAll()
        loadNextPageIfNeeded()
    }

    func loadNextPageIfNeeded() {
        guard !state.isLoading, canLoadNextPage else { return }

        state = items.isEmpty ? .loadingFirstPage : .loadingNextPage

        loadingTask = Task {
            do {
                let response = try await networkService.fetchNewsFeed(
                    page: currentPage,
                    pageSize: pageSize
                )

                totalCount = response.totalCount
                items.append(contentsOf: response.news)
                currentPage += 1
                state = .idle
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func createAlert() {
        
    }

    deinit {
        loadingTask?.cancel()
    }
}
