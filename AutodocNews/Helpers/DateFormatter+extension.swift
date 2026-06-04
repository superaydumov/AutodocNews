//
//  DateFormatter+extension.swift
//  AutodocNews
//
//  Created by Айдумов Эльдар on 04.06.2026.
//

import Foundation

extension DateFormatter {

    func formatDate(_ raw: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [
            .withFullDate,
            .withDashSeparatorInDate,
            .withTime,
            .withColonSeparatorInTime
        ]

        guard let date = iso.date(from: raw) else { return raw }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }
}
