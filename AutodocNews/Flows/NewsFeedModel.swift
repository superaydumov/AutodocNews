//
//  NewsFeedModel.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 03.06.2026.
//

import UIKit

struct NewsFeedItem: Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: NewsFeedItem, rhs: NewsFeedItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct NewsFeedResponse: Codable {
    let news: [NewsFeedItem]
    let totalCount: Int
}
