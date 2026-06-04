//
//  NewsFeedViewModelTests.swift
//  AutodocNewsTests
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import XCTest
import Combine
@testable import AutodocNews

    // MARK: - Mock Data

final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<NewsFeedResponse, Error> = .success(NewsFeedResponse(news: [], totalCount: 0))
    var fetchCallCount = 0
    var lastRequestedPage: Int?

    func fetchNewsFeed(page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        fetchCallCount += 1
        lastRequestedPage = page

        return try result.get()
    }
}

    // MARK: - Tests

@MainActor
final class NewsFeedViewModelTests: XCTestCase {

    private let mockNetworkService = MockNetworkService()
    private lazy var viewModel = NewsFeedViewModel(networkService: mockNetworkService)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - loadFirstPage test

    func testLoadFirstPageWithReplacingItems() async {
        mockNetworkService.result = .success(makeResponse(count: 3, total: 10))
        await loadAndWait()

        XCTAssertEqual(viewModel.items.count, 3)

        mockNetworkService.result = .success(makeResponse(count: 2, total: 5))
        viewModel.loadFirstPage()
        await Task.yield()
        await waitForLoading()

        XCTAssertEqual(viewModel.items.count, 2, "loadFirstPage must discard previously loaded items")
    }

    func testResetPageToFirst() async {
        mockNetworkService.result = .success(makeResponse(count: 15, total: 100))
        await loadAndWait()
        await loadAndWait()

        let pageAfterTwoLoads = mockNetworkService.lastRequestedPage

        viewModel.loadFirstPage()
        await Task.yield()
        await waitForLoading()

        XCTAssertEqual(
            mockNetworkService.lastRequestedPage,
            1,
            "loadFirstPage must restart from page 1 (but it was \(pageAfterTwoLoads ?? -1))"
        )
    }

    // MARK: - loadNextPageIfNeeded test

    func testLoadNextPageWhileAlreadyLoading() {
        mockNetworkService.result = .success(makeResponse(count: 5, total: 100))
        viewModel.loadNextPageIfNeeded()

        let callsBefore = mockNetworkService.fetchCallCount
        viewModel.loadNextPageIfNeeded()

        XCTAssertEqual(
            mockNetworkService.fetchCallCount,
            callsBefore,
            "Second call while loading should be ignored"
        )
    }

    func testLoadNextPageWhenAllLoaded() async {
        mockNetworkService.result = .success(makeResponse(count: 3, total: 3))
        await loadAndWait()

        let callsBefore = mockNetworkService.fetchCallCount
        viewModel.loadNextPageIfNeeded()

        XCTAssertEqual(
            mockNetworkService.fetchCallCount,
            callsBefore,
            "Should not fetch when all items are already loaded"
        )
    }

    // MARK: - Successful load test

    func testLoadItemsSuccessfully() async {
        mockNetworkService.result = .success(makeResponse(count: 5, total: 20))
        await loadAndWait()

        XCTAssertEqual(viewModel.items.count, 5)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadIncrementsPage() async {
        mockNetworkService.result = .success(makeResponse(count: 15, total: 100))

        await loadAndWait()
        XCTAssertEqual(mockNetworkService.lastRequestedPage, 1)

        await loadAndWait()
        XCTAssertEqual(mockNetworkService.lastRequestedPage, 2)
    }

    func testLoadNextPageIfNeeded_accumulatesAcrossPages() async {
        mockNetworkService.result = .success(makeResponse(count: 5, total: 30))
        await loadAndWait()
        await loadAndWait()

        XCTAssertEqual(viewModel.items.count, 10)
    }

    // MARK: - Error handling test

    func testLoadSetsErrorMessageOnFailure() async {
        mockNetworkService.result = .failure(URLError(.notConnectedToInternet))
        await loadAndWait()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadClearsErrorMessageOnRetry() async {
        mockNetworkService.result = .failure(URLError(.notConnectedToInternet))
        await loadAndWait()
        XCTAssertNotNil(viewModel.errorMessage)

        mockNetworkService.result = .success(makeResponse(count: 2, total: 2))
        await loadAndWait()

        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadDoNotAppendItemsOnFailure() async {
        mockNetworkService.result = .failure(URLError(.timedOut))
        await loadAndWait()

        XCTAssertTrue(viewModel.items.isEmpty)
    }

    // MARK: - isLoading state test

    func testIsLoadingAfterSuccess() async {
        mockNetworkService.result = .success(makeResponse(count: 1, total: 1))
        await loadAndWait()
        XCTAssertFalse(viewModel.isLoading)
    }

    func testIsLoadingAfterFailure() async {
        mockNetworkService.result = .failure(URLError(.cancelled))
        await loadAndWait()
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Helpers

    private func makeResponse(count: Int, total: Int) -> NewsFeedResponse {
        let items = (0..<count).map { i in
            NewsFeedItem(
                id: i,
                title: "Title \(i)",
                description: "Description",
                publishedDate: "2026-06-04T00:00:00",
                url: "https://example.com/\(i)",
                fullUrl: "https://example.com/full/\(i)",
                titleImageUrl: nil,
                categoryType: "news"
            )
        }
        return NewsFeedResponse(news: items, totalCount: total)
    }

    private func loadAndWait() async {
        viewModel.loadNextPageIfNeeded()
        await waitForLoading()
    }

    private func waitForLoading() async {
        await Task.yield()

        var attempts = 0
        while viewModel.isLoading, attempts < 50 {
            await Task.yield()
            attempts += 1
        }
    }
}
