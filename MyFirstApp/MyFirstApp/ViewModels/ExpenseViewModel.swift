//
//  ExpenseViewModel.swift
//  MyFirstApp
//

import Foundation
import SwiftData

@Observable
final class ExpenseViewModel {
    private let modelContext: ModelContext

    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - 3.2.1 Add a new expense

    /// Add a new expense with amount, card, date, optional label, category, and bonus category
    /// - Parameters:
    ///   - amount: The expense amount in SGD
    ///   - card: The credit card to associate with
    ///   - date: The date of the expense (defaults to today)
    ///   - label: Optional note describing the expense (e.g., "Chicken rice")
    ///   - category: Optional user expense category for tracking
    ///   - bonusCategory: Optional bonus category for cards with category caps
    func addExpense(
        amount: Decimal,
        card: CreditCard,
        date: Date = Date(),
        label: String? = nil,
        category: ExpenseCategory? = nil,
        bonusCategory: BonusCategory? = nil
    ) {
        let expense = Expense(
            amount: amount,
            date: date,
            label: label,
            category: category,
            bonusCategory: bonusCategory
        )

        card.expenses.append(expense)
        save()
    }

    // MARK: - 3.2.2 Delete an expense

    /// Delete an expense
    /// - Parameter expense: The expense to delete
    func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        save()
    }

    /// Delete multiple expenses
    /// - Parameter expenses: The expenses to delete
    func deleteExpenses(_ expenses: [Expense]) {
        for expense in expenses {
            modelContext.delete(expense)
        }
        save()
    }

    // MARK: - 3.2.3 Fetch expenses for a specific card within date range

    /// Fetch all expenses for a card
    /// - Parameter card: The credit card to fetch expenses for
    /// - Returns: Array of expenses sorted by date (newest first)
    func fetchExpenses(for card: CreditCard) -> [Expense] {
        return card.expenses.sorted { $0.date > $1.date }
    }

    /// Fetch expenses for a specific card within a date range
    /// - Parameters:
    ///   - card: The credit card to fetch expenses for
    ///   - dateRange: The date range to filter expenses
    /// - Returns: Array of expenses within the date range, sorted by date (newest first)
    func fetchExpenses(for card: CreditCard, in dateRange: DateRange) -> [Expense] {
        return card.expenses
            .filter { $0.date.isWithin(start: dateRange.start, end: dateRange.end) }
            .sorted { $0.date > $1.date }
    }

    /// Fetch expenses for a specific card in its current cycle
    /// - Parameter card: The credit card to fetch expenses for
    /// - Returns: Array of expenses in the current cycle, sorted by date (newest first)
    func fetchCurrentCycleExpenses(for card: CreditCard) -> [Expense] {
        let dateRange = DateRangeCalculator.calculateCurrentCycle(
            cycleType: card.cycleType,
            statementDate: card.statementDate
        )
        return fetchExpenses(for: card, in: dateRange)
    }

    /// Fetch all expenses across all cards within a date range
    /// - Parameter dateRange: The date range to filter expenses
    /// - Returns: Array of all expenses within the date range
    func fetchAllExpenses(in dateRange: DateRange) -> [Expense] {
        let startDate = dateRange.start
        let endDate = dateRange.end

        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { expense in
                expense.date >= startDate && expense.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch expenses: \(error.localizedDescription)"
            return []
        }
    }

    // MARK: - Private Helpers

    private func save() {
        do {
            try modelContext.save()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
