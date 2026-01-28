//
//  TransactionRow.swift
//  MyFirstApp
//

import SwiftUI

struct TransactionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let expense: Expense
    let showCardBadge: Bool

    init(expense: Expense, showCardBadge: Bool = true) {
        self.expense = expense
        self.showCardBadge = showCardBadge
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            // Main line: Label ... Amount (receipt line-item style)
            HStack(spacing: 0) {
                Text((expense.label ?? "EXPENSE").uppercased())
                    .font(ReceiptTypography.bodyLarge)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                    .lineLimit(1)

                DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))
                    .padding(.horizontal, Spacing.xs)

                Text(expense.amount.formattedAsCurrency)
                    .font(ReceiptTypography.amountLarge)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
            }

            // Subline: Card badge (optional)
            if showCardBadge, let card = expense.card {
                CardBadge(card: card)
            }
        }
        .padding(.vertical, Spacing.sm)
        .contentShape(Rectangle())
    }
}

// Swipeable version with delete action
struct SwipeableTransactionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let expense: Expense
    let showCardBadge: Bool
    let onDelete: () -> Void

    init(expense: Expense, showCardBadge: Bool = true, onDelete: @escaping () -> Void) {
        self.expense = expense
        self.showCardBadge = showCardBadge
        self.onDelete = onDelete
    }

    var body: some View {
        TransactionRow(expense: expense, showCardBadge: showCardBadge)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    HapticManager.deleteSwipe()
                    onDelete()
                } label: {
                    Text("[DELETE]")
                        .font(ReceiptTypography.captionMedium)
                }
            }
    }
}

#Preview {
    TransactionRowPreview()
}

private struct TransactionRowPreview: View {
    var body: some View {
        let card = CreditCard(
            bank: .citibank,
            network: .visa,
            cardName: "Rewards Card"
        )

        let expense1 = Expense(
            amount: 45.80,
            date: Date(),
            label: "Dinner at Marché"
        )

        let expense2 = Expense(
            amount: 123.50,
            date: Date(),
            label: "NTUC Groceries"
        )

        return VStack(spacing: 0) {
            TransactionRow(expense: expense1, showCardBadge: true)
            Divider()
            TransactionRow(expense: expense2, showCardBadge: true)
            Divider()
            TransactionRow(expense: expense1, showCardBadge: false)
        }
        .padding(.horizontal)
        .onAppear {
            expense1.card = card
            expense2.card = CreditCard(bank: .dbs, network: .mastercard, cardName: "WWC")
        }
    }
}
