//
//  DateFormatterExtensionTests.swift
//  AutodocNewsTests
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import XCTest
@testable import AutodocNews

final class DateFormatterExtensionTests: XCTestCase {

    private let formatter = DateFormatter()

    func testForDate() {
        let result = formatter.formatDate("2026-06-04T12:30:00")
        XCTAssertFalse(result.isEmpty)
        XCTAssertNotEqual(result, "2026-06-04T12:30:00")
    }

    func testForString() {
        let raw = "not-a-date"
        let result = formatter.formatDate(raw)
        XCTAssertEqual(result, raw)
    }
}
