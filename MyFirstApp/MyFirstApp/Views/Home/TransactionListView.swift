//
//  TransactionListView.swift
//  MyFirstApp
//

import SwiftUI

struct TransactionListView: View {
    @Environment(\.colorScheme) private var colorScheme
    let expenses: [Expense]
    let showCardBadges: Bool
    let onDelete: ((Expense) -> Void)?

    init(
        expenses: [Expense],
        showCardBadges: Bool = true,
        onDelete: ((Expense) -> Void)? = nil
    ) {
        self.expenses = expenses
        self.showCardBadges = showCardBadges
        self.onDelete = onDelete
    }

    var body: some View {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            ForEach(groupedExpenses, id: \.date) { group in
                Section {
                    ForEach(group.expenses) { expense in
                        if let onDelete = onDelete {
                            SwipeableTransactionRow(
                                expense: expense,
                                showCardBadge: showCardBadges
                            ) {
                                onDelete(expense)
                            }
                        } else {
                            TransactionRow(expense: expense, showCardBadge: showCardBadges)
                        }
                    }
                } header: {
                    DateSectionHeader(
                        dateLabel: group.date.receiptDateLabel,
                        totalAmount: group.total
                    )
                    .background(ReceiptColors.paper(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var groupedExpenses: [ExpenseGroup] {
        let calendar = Calendar.current

        // Group by day
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.startOfDay(for: expense.date)
        }

        // Sort by date descending and create groups
        return grouped
            .map { date, expenses in
                ExpenseGroup(
                    date: date,
                    expenses: expenses.sorted { $0.date > $1.date },
                    total: expenses.reduce(Decimal.zero) { $0 + $1.amount }
                )
            }
            .sorted { $0.date > $1.date }
    }
}

private struct ExpenseGroup {
    let date: Date
    let expenses: [Expense]
    let total: Decimal
}

// Empty state view with receipt-style ASCII art
struct EmptyTransactionView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: String

    init(message: String = "No transactions yet") {
        self.message = message
    }

    private let asciiReceipt = """
    ╔═══════════════╗
    ║               ║
    ║   (empty)     ║
    ║               ║
    ╚═══════════════╝
    """

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text(asciiReceipt)
                .font(ReceiptTypography.bodySmall)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                .multilineTextAlignment(.center)

            Text(message.uppercased().letterSpaced)
                .font(ReceiptTypography.captionMedium)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

#Preview {
    TransactionListPreview()
}

private struct TransactionListPreview: View {
    var body: some View {
        let card = CreditCard(
            bank: .citibank,
            network: .visa,
            cardName: "Rewards Card"
        )

        let card2 = CreditCard(
            bank: .dbs,
            network: .mastercard,
            cardName: "WWC"
        )

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let expense1 = Expense(amount: 45.80, date: today, label: "Dinner at Marché")
        let expense2 = Expense(amount: 123.50, date: today, label: "NTUC Groceries")
        let expense3 = Expense(amount: 12.90, date: yesterday, label: "Starbucks")
        let expense4 = Expense(amount: 89.00, date: yesterday, label: "Grab Ride")

        return ScrollView {
            TransactionListView(
                expenses: [expense1, expense2, expense3, expense4],
                showCardBadges: true
            )
        }
        .onAppear {
            expense1.card = card
            expense2.card = card2
            expense3.card = card
            expense4.card = card2
        }
    }
}
