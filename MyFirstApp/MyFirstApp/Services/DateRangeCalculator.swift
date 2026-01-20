//
//  DateRangeCalculator.swift
//  MyFirstApp
//

import Foundation

struct DateRange {
    let start: Date
    let end: Date

    var displayString: String {
        "\(start.formattedShort) - \(end.formattedShort)"
    }
}

struct DateRangeCalculator {
    /// Calculates the current cycle date range based on cycle type and optional statement date
    /// - Parameters:
    ///   - cycleType: Whether the card uses calendar month or statement month cycle
    ///   - statementDate: Day of month for statement cycle (1-31), ignored for calendar month
    ///   - referenceDate: The date to calculate the cycle for (defaults to today)
    /// - Returns: DateRange containing the start and end dates of the current cycle
    static func calculateCurrentCycle(
        cycleType: CycleType,
        statementDate: Int? = nil,
        referenceDate: Date = Date()
    ) -> DateRange {
        switch cycleType {
        case .calendarMonth:
            return calculateCalendarMonthCycle(for: referenceDate)
        case .statementMonth:
            return calculateStatementMonthCycle(
                statementDate: statementDate ?? 1,
                for: referenceDate
            )
        }
    }

    /// Calendar month cycle: 1st of current month to last day of current month
    private static func calculateCalendarMonthCycle(for date: Date) -> DateRange {
        DateRange(start: date.startOfMonth, end: date.endOfMonth)
    }

    /// Statement month cycle: statement date of previous month to day before statement date of current month
    /// Example: If statement date is 15th and today is Jan 20, cycle is Dec 15 - Jan 14
    /// Example: If statement date is 15th and today is Jan 10, cycle is Nov 15 - Dec 14
    private static func calculateStatementMonthCycle(statementDate: Int, for date: Date) -> DateRange {
        let calendar = Calendar.current
        let currentDay = date.dayOfMonth

        // Clamp statement date to valid range (1-28 to avoid month-end issues)
        let safeStatementDate = min(max(statementDate, 1), 28)

        if currentDay >= safeStatementDate {
            // We're in the current cycle: this month's statement date to next month's statement date - 1
            let cycleStart = date.withDay(safeStatementDate) ?? date.startOfMonth
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: cycleStart) ?? cycleStart
            let cycleEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? date.endOfMonth
            return DateRange(start: cycleStart.startOfDay, end: cycleEnd.endOfDay)
        } else {
            // We're before this month's statement date, so we're in previous cycle
            // Cycle is: previous month's statement date to this month's statement date - 1
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: date) else {
                return DateRange(start: date.startOfMonth, end: date.endOfMonth)
            }
            let cycleStart = previousMonth.withDay(safeStatementDate) ?? previousMonth.startOfMonth
            guard let thisMonthStatementDate = date.withDay(safeStatementDate) else {
                return DateRange(start: cycleStart.startOfDay, end: date.endOfMonth)
            }
            let cycleEnd = calendar.date(byAdding: .day, value: -1, to: thisMonthStatementDate) ?? date.endOfMonth
            return DateRange(start: cycleStart.startOfDay, end: cycleEnd.endOfDay)
        }
    }

    /// Returns the calendar month date range for the given date (for monthly overview)
    static func calendarMonthRange(for date: Date = Date()) -> DateRange {
        DateRange(start: date.startOfMonth, end: date.endOfMonth)
    }
}
