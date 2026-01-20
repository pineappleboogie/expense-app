//
//  Date+Extensions.swift
//  MyFirstApp
//

import Foundation

extension Date {
    /// Returns the start of the month (first day at 00:00:00)
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// Returns the end of the month (last day at 23:59:59)
    var endOfMonth: Date {
        let calendar = Calendar.current
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return self
        }
        return calendar.date(byAdding: .second, value: -1, to: startOfNextMonth) ?? self
    }

    /// Returns the start of the day (00:00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the end of the day (23:59:59)
    var endOfDay: Date {
        let calendar = Calendar.current
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return self
        }
        return calendar.date(byAdding: .second, value: -1, to: startOfNextDay) ?? self
    }

    /// Formats the date as "MMM d, yyyy" (e.g., "Jan 15, 2025")
    var formattedMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Formats the date as "MMMM yyyy" (e.g., "January 2025")
    var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    /// Formats the date as "MMM d" (e.g., "Jan 15")
    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// Returns the day of month (1-31)
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Returns date with the given day of month, or nil if invalid
    func withDay(_ day: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: self)
        components.day = day
        return calendar.date(from: components)
    }

    /// Checks if this date is within the given date range (inclusive)
    func isWithin(start: Date, end: Date) -> Bool {
        self >= start.startOfDay && self <= end.endOfDay
    }
}
