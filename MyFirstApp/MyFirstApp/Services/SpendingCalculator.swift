//
//  SpendingCalculator.swift
//  MyFirstApp
//

import Foundation

/// Represents the threshold status for a card's spending
enum ThresholdStatus: String {
    case belowMinimum = "Below Minimum"
    case minimumMet = "Minimum Met"
    case inRange = "In Range"
    case overMaximum = "Over Maximum"
    case noThreshold = "No Threshold"

    var color: String {
        switch self {
        case .belowMinimum:
            return "orange"
        case .minimumMet, .inRange:
            return "green"
        case .overMaximum:
            return "red"
        case .noThreshold:
            return "gray"
        }
    }

    var icon: String {
        switch self {
        case .belowMinimum:
            return "exclamationmark.circle.fill"
        case .minimumMet, .inRange:
            return "checkmark.circle.fill"
        case .overMaximum:
            return "xmark.circle.fill"
        case .noThreshold:
            return "minus.circle.fill"
        }
    }
}

/// Represents the status of a category cap's spending
enum CategoryCapStatus {
    case belowMinimum(spent: Decimal, minRequired: Decimal)
    case inProgress(spent: Decimal, cap: Decimal)
    case maxedOut(cap: Decimal)

    var isEarningBonus: Bool {
        switch self {
        case .belowMinimum:
            return false
        case .inProgress, .maxedOut:
            return true
        }
    }
}

/// Progress information for threshold tracking
struct ThresholdProgress {
    let minProgress: Double  // 0.0 to 1.0+
    let maxProgress: Double  // 0.0 to 1.0+
    let currentSpend: Decimal
    let minThreshold: Decimal?
    let maxThreshold: Decimal?
}

/// Progress information for a category cap
struct CategoryCapProgress {
    let category: BonusCategory
    let spent: Decimal
    let minSpend: Decimal?
    let capAmount: Decimal
    let bonusRate: Double
    let status: CategoryCapStatus
    let progress: Double  // Progress toward cap (after meeting min if applicable)
}

struct SpendingCalculator {

    // MARK: - Total Spending Calculation

    /// Calculate total spending for a card within a date range
    /// - Parameters:
    ///   - card: The credit card to calculate spending for
    ///   - dateRange: The date range to filter expenses
    /// - Returns: Total spending amount as Decimal
    static func calculateTotalSpending(for card: CreditCard, in dateRange: DateRange) -> Decimal {
        card.expenses
            .filter { $0.date.isWithin(start: dateRange.start, end: dateRange.end) }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }

    /// Calculate total spending for a card in its current cycle
    static func calculateCurrentCycleSpending(for card: CreditCard) -> Decimal {
        let dateRange = DateRangeCalculator.calculateCurrentCycle(
            cycleType: card.cycleType,
            statementDate: card.statementDate
        )
        return calculateTotalSpending(for: card, in: dateRange)
    }

    // MARK: - Category Spending Calculation

    /// Calculate spending per bonus category for cards with category caps
    /// - Parameters:
    ///   - card: The credit card to calculate spending for
    ///   - dateRange: The date range to filter expenses
    /// - Returns: Dictionary mapping bonus category to spending amount
    static func calculateSpendingPerCategory(
        for card: CreditCard,
        in dateRange: DateRange
    ) -> [BonusCategory: Decimal] {
        var categorySpending: [BonusCategory: Decimal] = [:]

        let expenses = card.expenses.filter {
            $0.date.isWithin(start: dateRange.start, end: dateRange.end)
        }

        for expense in expenses {
            let category = expense.bonusCategory ?? .general
            categorySpending[category, default: .zero] += expense.amount
        }

        return categorySpending
    }

    // MARK: - Threshold Status

    /// Determine threshold status (below min, min met, in range, over max)
    /// - Parameters:
    ///   - currentSpend: Current spending amount
    ///   - minThreshold: Optional minimum spending threshold
    ///   - maxThreshold: Optional maximum spending threshold
    /// - Returns: The current threshold status
    static func determineThresholdStatus(
        currentSpend: Decimal,
        minThreshold: Decimal?,
        maxThreshold: Decimal?
    ) -> ThresholdStatus {
        // No thresholds set
        guard minThreshold != nil || maxThreshold != nil else {
            return .noThreshold
        }

        // Check if over maximum first
        if let max = maxThreshold, currentSpend > max {
            return .overMaximum
        }

        // Check if below minimum
        if let min = minThreshold, currentSpend < min {
            return .belowMinimum
        }

        // Has minimum and met it
        if minThreshold != nil {
            if maxThreshold != nil {
                return .inRange
            }
            return .minimumMet
        }

        // Only has maximum threshold and we're under it
        return .inRange
    }

    // MARK: - Progress Percentages

    /// Calculate progress percentages for min and max thresholds
    /// - Parameters:
    ///   - currentSpend: Current spending amount
    ///   - minThreshold: Optional minimum spending threshold
    ///   - maxThreshold: Optional maximum spending threshold
    /// - Returns: ThresholdProgress containing progress values
    static func calculateProgressPercentages(
        currentSpend: Decimal,
        minThreshold: Decimal?,
        maxThreshold: Decimal?
    ) -> ThresholdProgress {
        let minProgress = currentSpend.progressToward(minThreshold)
        let maxProgress = currentSpend.progressToward(maxThreshold)

        return ThresholdProgress(
            minProgress: minProgress,
            maxProgress: maxProgress,
            currentSpend: currentSpend,
            minThreshold: minThreshold,
            maxThreshold: maxThreshold
        )
    }

    // MARK: - Category Cap Progress

    /// Calculate category cap progress including min spend unlock logic
    /// - Parameters:
    ///   - card: The credit card with category caps
    ///   - dateRange: The date range to filter expenses
    /// - Returns: Array of CategoryCapProgress for each category cap
    static func calculateCategoryCapProgress(
        for card: CreditCard,
        in dateRange: DateRange
    ) -> [CategoryCapProgress] {
        guard card.hasCategoryCaps else { return [] }

        let categorySpending = calculateSpendingPerCategory(for: card, in: dateRange)

        return card.categoryCaps.map { cap in
            let spent = categorySpending[cap.category] ?? .zero
            let status = determineCategoryCapStatus(
                spent: spent,
                minSpend: cap.minSpend,
                capAmount: cap.capAmount
            )
            let progress = calculateCategoryProgress(
                spent: spent,
                minSpend: cap.minSpend,
                capAmount: cap.capAmount
            )

            return CategoryCapProgress(
                category: cap.category,
                spent: spent,
                minSpend: cap.minSpend,
                capAmount: cap.capAmount,
                bonusRate: cap.bonusRate,
                status: status,
                progress: progress
            )
        }
    }

    /// Determine the status of a category cap based on spending
    private static func determineCategoryCapStatus(
        spent: Decimal,
        minSpend: Decimal?,
        capAmount: Decimal
    ) -> CategoryCapStatus {
        // If there's a minimum spend requirement and we haven't met it
        if let min = minSpend, spent < min {
            return .belowMinimum(spent: spent, minRequired: min)
        }

        // We've met the minimum (or there is none), check if maxed out
        if spent >= capAmount {
            return .maxedOut(cap: capAmount)
        }

        // We're in progress toward the cap
        return .inProgress(spent: spent, cap: capAmount)
    }

    /// Calculate progress toward cap (accounting for min spend if applicable)
    private static func calculateCategoryProgress(
        spent: Decimal,
        minSpend: Decimal?,
        capAmount: Decimal
    ) -> Double {
        // If there's a min spend and we haven't met it, progress is toward the min
        if let min = minSpend, spent < min {
            return spent.progressToward(min)
        }

        // Otherwise, progress is toward the cap
        return spent.progressToward(capAmount)
    }

    // MARK: - Summary Calculations

    /// Get complete spending summary for a card in its current cycle
    static func getCardSpendingSummary(for card: CreditCard) -> CardSpendingSummary {
        let dateRange = DateRangeCalculator.calculateCurrentCycle(
            cycleType: card.cycleType,
            statementDate: card.statementDate
        )

        let totalSpending = calculateTotalSpending(for: card, in: dateRange)

        let thresholdStatus = determineThresholdStatus(
            currentSpend: totalSpending,
            minThreshold: card.minSpendingThreshold,
            maxThreshold: card.maxSpendingThreshold
        )

        let thresholdProgress = calculateProgressPercentages(
            currentSpend: totalSpending,
            minThreshold: card.minSpendingThreshold,
            maxThreshold: card.maxSpendingThreshold
        )

        let categoryCapProgress = card.hasCategoryCaps
            ? calculateCategoryCapProgress(for: card, in: dateRange)
            : []

        return CardSpendingSummary(
            card: card,
            dateRange: dateRange,
            totalSpending: totalSpending,
            thresholdStatus: thresholdStatus,
            thresholdProgress: thresholdProgress,
            categoryCapProgress: categoryCapProgress
        )
    }
}

/// Complete spending summary for a card
struct CardSpendingSummary {
    let card: CreditCard
    let dateRange: DateRange
    let totalSpending: Decimal
    let thresholdStatus: ThresholdStatus
    let thresholdProgress: ThresholdProgress
    let categoryCapProgress: [CategoryCapProgress]
}
