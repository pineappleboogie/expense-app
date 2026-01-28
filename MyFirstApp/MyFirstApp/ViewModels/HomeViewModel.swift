//
//  HomeViewModel.swift
//  MyFirstApp
//

import Foundation
import SwiftData

@Observable
final class HomeViewModel {
    private let modelContext: ModelContext

    private(set) var cards: [CreditCard] = []
    private(set) var cardSummaries: [UUID: CardSpendingSummary] = [:]
    private(set) var allExpenses: [Expense] = []
    private(set) var monthlyOverview: MonthlyOverview?

    var selectedCardId: UUID?
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Data Fetching

    /// Refresh all home data
    func refresh() {
        fetchCards()
        calculateMonthlyOverview()
        fetchCurrentMonthExpenses()
    }

    /// Fetch all cards sorted by display order
    private func fetchCards() {
        let descriptor = FetchDescriptor<CreditCard>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )

        do {
            cards = try modelContext.fetch(descriptor)
            // Calculate summaries for each card
            cardSummaries = Dictionary(
                uniqueKeysWithValues: cards.map { card in
                    (card.id, SpendingCalculator.getCardSpendingSummary(for: card))
                }
            )
        } catch {
            errorMessage = "Failed to fetch cards: \(error.localizedDescription)"
            cards = []
            cardSummaries = [:]
        }
    }

    /// Calculate monthly overview for header
    private func calculateMonthlyOverview() {
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

            monthlyOverview = MonthlyOverview(
                dateRange: dateRange,
                totalSpending: totalSpending,
                cardCount: cards.count
            )
        } catch {
            errorMessage = "Failed to calculate monthly overview: \(error.localizedDescription)"
        }
    }

    /// Fetch all expenses for the current calendar month
    private func fetchCurrentMonthExpenses() {
        let dateRange = DateRangeCalculator.calendarMonthRange()
        let startDate = dateRange.start
        let endDate = dateRange.end

        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.date >= startDate && expense.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            allExpenses = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch expenses: \(error.localizedDescription)"
            allExpenses = []
        }
    }

    // MARK: - Computed Properties

    /// Selected card (if any)
    var selectedCard: CreditCard? {
        guard let id = selectedCardId else { return nil }
        return cards.first { $0.id == id }
    }

    /// Summary for the selected card
    var selectedCardSummary: CardSpendingSummary? {
        guard let id = selectedCardId else { return nil }
        return cardSummaries[id]
    }

    /// Whether a card is currently selected
    var hasSelectedCard: Bool {
        selectedCardId != nil
    }

    /// Total spending for the month (from overview)
    var totalMonthlySpending: Decimal {
        monthlyOverview?.totalSpending ?? .zero
    }

    /// Current month label
    var monthLabel: String {
        monthlyOverview?.monthLabel ?? Date().formattedMonthYear
    }

    // MARK: - Filtered Expenses

    /// Get expenses filtered by selected card (or all if none selected)
    var filteredExpenses: [Expense] {
        guard let cardId = selectedCardId else {
            return allExpenses
        }
        return allExpenses.filter { $0.card?.id == cardId }
    }

    /// Whether to show card badges on transactions (only when no card is selected)
    var showCardBadges: Bool {
        selectedCardId == nil
    }

    // MARK: - Card Helpers

    /// Get summary for a specific card
    func summary(for card: CreditCard) -> CardSpendingSummary? {
        cardSummaries[card.id]
    }

    /// Get reset date label for a card ("8 DAYS" or "FEB 1")
    func resetLabel(for card: CreditCard) -> String {
        guard let summary = summary(for: card) else { return "" }

        let daysRemaining = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: summary.dateRange.end
        ).day ?? 0

        if daysRemaining <= 0 {
            return "RESETS TODAY"
        } else if daysRemaining == 1 {
            return "1 DAY"
        } else if daysRemaining <= 14 {
            return "\(daysRemaining) DAYS"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: summary.dateRange.end).uppercased()
        }
    }

    // MARK: - Actions

    /// Select a card
    func selectCard(_ card: CreditCard) {
        selectedCardId = card.id
    }

    /// Deselect the current card
    func deselectCard() {
        selectedCardId = nil
    }

    /// Toggle card selection
    func toggleCardSelection(_ card: CreditCard) {
        if selectedCardId == card.id {
            selectedCardId = nil
        } else {
            selectedCardId = card.id
        }
    }

    /// Delete an expense
    func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)

        do {
            try modelContext.save()
            refresh()
        } catch {
            errorMessage = "Failed to delete expense: \(error.localizedDescription)"
        }
    }
}
