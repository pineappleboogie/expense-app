//
//  HomeView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: HomeViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    HomeContentView(viewModel: viewModel)
                } else {
                    ProgressView()
                        .tint(ReceiptColors.ink(for: colorScheme))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("HOME".letterSpaced)
                            .font(ReceiptTypography.titleMedium)
                            .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                        Spacer()

                        if let viewModel = viewModel {
                            Text(viewModel.monthLabel.uppercased().letterSpaced)
                                .font(ReceiptTypography.titleMedium)
                                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                        }
                    }
                }
            }
            .toolbarBackground(ReceiptColors.paper(for: colorScheme), for: .navigationBar)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(modelContext: modelContext)
            }
            viewModel?.refresh()
        }
    }
}

private struct HomeContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Collapsible Total Spend Header
            TotalSpendHeader(
                totalSpent: viewModel.totalMonthlySpending,
                isCollapsed: viewModel.hasSelectedCard,
                monthLabel: viewModel.monthLabel
            )

            // Card Carousel
            CardCarouselView(
                cards: viewModel.cards,
                summaries: viewModel.cardSummaries,
                selectedCardId: $viewModel.selectedCardId
            )
            .padding(.vertical, Spacing.sm)

            // Dotted Divider
            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)

            // Transaction List
            ScrollView {
                if viewModel.filteredExpenses.isEmpty {
                    EmptyTransactionView(
                        message: viewModel.hasSelectedCard
                            ? "No transactions for this card"
                            : "No transactions this month"
                    )
                } else {
                    TransactionListView(
                        expenses: viewModel.filteredExpenses,
                        showCardBadges: viewModel.showCardBadges,
                        onDelete: { expense in
                            HapticManager.deleteSwipe()
                            viewModel.deleteExpense(expense)
                        }
                    )
                }
            }
        }
        .background(ReceiptColors.paper(for: colorScheme))
    }
}

// Empty state for no cards
private struct NoCardsView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let asciiCard = """
    ╔══════════════════╗
    ║                  ║
    ║   [NO CARDS]     ║
    ║                  ║
    ╚══════════════════╝
    """

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text(asciiCard)
                .font(ReceiptTypography.bodySmall)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))

            Text("NO CARDS YET".letterSpaced)
                .font(ReceiptTypography.titleMedium)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

            Text("Add a card to start tracking")
                .font(ReceiptTypography.bodyMedium)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
