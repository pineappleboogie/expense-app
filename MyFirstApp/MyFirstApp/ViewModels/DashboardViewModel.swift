//
//  DashboardViewModel.swift
//  MyFirstApp
//

import Foundation
import SwiftData

@Observable
final class DashboardViewModel {
    private let modelContext: ModelContext

    private(set) var cardSummaries: [CardSpendingSummary] = []
    private(set) var monthlyOverview: MonthlyOverview?
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - 3.3.1 Calculate monthly overview total (calendar month, all cards)

    /// Calculate total spending for the current calendar month across all cards
    func calculateMonthlyOverview() {
        let dateRange = DateRangeCalculator.calendarMonthRange()
        let startDate = dateRange.start
        let endDate = dateRange.end

        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.date >= startDate && expense.date <= endDate
            }
        )

        do {
            let expenses = try modelContext.fetch(descriptor)
            let totalSpending = expenses.reduce(Decimal.zero) { $0 + $1.amount }

            let cardDescriptor = FetchDescriptor<CreditCard>()
            let cards = try modelContext.fetch(cardDescriptor)

            monthlyOverview = MonthlyOverview(
                dateRange: dateRange,
                totalSpending: totalSpending,
                cardCount: cards.count
            )
        } catch {
            errorMessage = "Failed to calculate monthly overview: \(error.localizedDescription)"
        }
    }

    // MARK: - 3.3.2 Fetch all cards with their current cycle spending summaries

    /// Fetch all cards and calculate their spending summaries for the current cycle
    func fetchCardsWithSummaries() {
        let descriptor = FetchDescriptor<CreditCard>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )

        do {
            let cards = try modelContext.fetch(descriptor)
            cardSummaries = cards.map { SpendingCalculator.getCardSpendingSummary(for: $0) }
        } catch {
            errorMessage = "Failed to fetch cards: \(error.localizedDescription)"
            cardSummaries = []
        }
    }

    /// Refresh all dashboard data
    func refresh() {
        calculateMonthlyOverview()
        fetchCardsWithSummaries()
    }

    // MARK: - 3.3.3 Computed properties for each card's threshold status and progress

    /// Get the spending summary for a specific card
    func summary(for card: CreditCard) -> CardSpendingSummary? {
        cardSummaries.first { $0.card.id == card.id }
    }

    /// Get the threshold status for a specific card
    func thresholdStatus(for card: CreditCard) -> ThresholdStatus {
        summary(for: card)?.thresholdStatus ?? .noThreshold
    }

    /// Get the threshold progress for a specific card
    func thresholdProgress(for card: CreditCard) -> ThresholdProgress? {
        summary(for: card)?.thresholdProgress
    }

    /// Get minimum progress percentage for a card (0.0 to 1.0+)
    func minProgress(for card: CreditCard) -> Double {
        summary(for: card)?.thresholdProgress.minProgress ?? 0
    }

    /// Get maximum progress percentage for a card (0.0 to 1.0+)
    func maxProgress(for card: CreditCard) -> Double {
        summary(for: card)?.thresholdProgress.maxProgress ?? 0
    }

    /// Get total spending for a card in its current cycle
    func totalSpending(for card: CreditCard) -> Decimal {
        summary(for: card)?.totalSpending ?? .zero
    }

    /// Get the date range for a card's current cycle
    func dateRange(for card: CreditCard) -> DateRange? {
        summary(for: card)?.dateRange
    }

    // MARK: - 3.3.4 Get category cap progress for cards with hasCategoryCaps = true

    /// Get category cap progress for a specific card
    /// - Parameter card: The credit card to get category cap progress for
    /// - Returns: Array of CategoryCapProgress if card has category caps, empty array otherwise
    func categoryCapProgress(for card: CreditCard) -> [CategoryCapProgress] {
        summary(for: card)?.categoryCapProgress ?? []
    }

    /// Check if a card has category caps
    func hasCategoryCaps(_ card: CreditCard) -> Bool {
        card.hasCategoryCaps
    }

    /// Get progress for a specific category cap
    /// - Parameters:
    ///   - card: The credit card
    ///   - category: The bonus category to check
    /// - Returns: CategoryCapProgress if found, nil otherwise
    func categoryCapProgress(for card: CreditCard, category: BonusCategory) -> CategoryCapProgress? {
        categoryCapProgress(for: card).first { $0.category == category }
    }
}

// MARK: - Supporting Types

/// Monthly overview data for dashboard header
struct MonthlyOverview {
    let dateRange: DateRange
    let totalSpending: Decimal
    let cardCount: Int

    var monthLabel: String {
        dateRange.start.formattedMonthYear
    }
}
