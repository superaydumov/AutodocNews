//
//  NewsFeedItemTests.swift
//  AutodocNewsTests
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import XCTest
@testable import AutodocNews

final class NewsFeedItemTests: XCTestCase {

    // MARK: - Decoding

    func testDecodingAllFields() throws {
        let json = """
        {
            "id": 52,
            "title": "Title",
            "description": "Description",
            "publishedDate": "2026-06-04T00:00:00",
            "url": "https://example.com/article",
            "fullUrl": "https://example.com/article/full",
            "titleImageUrl": "https://example.com/image.jpg",
            "categoryType": "news"
        }
        """

        guard let jsonData = json.data(using: .utf8) else {
            throw NSError(domain: "bad string", code: 1, userInfo: nil)
        }

        let item = try JSONDecoder().decode(NewsFeedItem.self, from: jsonData)

        XCTAssertEqual(item.id, 52)
        XCTAssertEqual(item.title, "Title")
        XCTAssertEqual(item.description, "Description")
        XCTAssertEqual(item.publishedDate, "2026-06-04T00:00:00")
        XCTAssertEqual(item.url, "https://example.com/article")
        XCTAssertEqual(item.fullUrl, "https://example.com/article/full")
        XCTAssertEqual(item.titleImageUrl, "https://example.com/image.jpg")
        XCTAssertEqual(item.categoryType, "news")
    }

    func testDecodingNilTitleImageUrl() throws {
        let json = """
        {
            "id": 1,
            "title": "Title",
            "description": "Description",
            "publishedDate": "2026-06-04T00:00:00",
            "url": "https://example.com/article",
            "fullUrl": "https://example.com/article/full",
            "titleImageUrl": null,
            "categoryType": "news"
        }
        """

        guard let jsonData = json.data(using: .utf8) else {
            throw NSError(domain: "bad string", code: 1, userInfo: nil)
        }

        let item = try JSONDecoder().decode(NewsFeedItem.self, from: jsonData)

        XCTAssertNil(item.titleImageUrl)
    }

    func testDecodingMissingTitleImageUrl() throws {
        let json = """
        {
            "id": 2,
            "title": "Title",
            "description": "Description",
            "publishedDate": "2026-06-04T00:00:00",
            "url": "https://example.com",
            "fullUrl": "https://example.com/full",
            "categoryType": "news"
        }
        """

        guard let jsonData = json.data(using: .utf8) else {
            throw NSError(domain: "bad string", code: 1, userInfo: nil)
        }

        let item = try JSONDecoder().decode(NewsFeedItem.self, from: jsonData)

        XCTAssertNil(item.titleImageUrl)
    }

    func testDecodingInvalidJSON() {
        let jsonString = "{ invalid }"

        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTFail("Failed to convert string to data")
            return
        }

        XCTAssertThrowsError(try JSONDecoder().decode(NewsFeedItem.self, from: jsonData))
    }

    // MARK: - NewsFeedResponse decoding

    func testResponseDecoding() throws {
        let json = """
        {
            "news": [
                {
                    "id": 1,
                    "title": "Title",
                    "description": "Description",
                    "publishedDate": "2026-06-04T00:00:00",
                    "url": "https://a.com",
                    "fullUrl": "https://a.com/full",
                    "titleImageUrl": null,
                    "categoryType": "news"
                }
            ],
            "totalCount": 100
        }
        """

        guard let jsonData = json.data(using: .utf8) else {
            throw NSError(domain: "bad string", code: 1, userInfo: nil)
        }

        let response = try JSONDecoder().decode(NewsFeedResponse.self, from: jsonData)

        XCTAssertEqual(response.totalCount, 100)
        XCTAssertEqual(response.news.count, 1)
        XCTAssertEqual(response.news[0].id, 1)
    }
}
