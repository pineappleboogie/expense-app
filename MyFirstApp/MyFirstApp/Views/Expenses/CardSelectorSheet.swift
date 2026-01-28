//
//  CardSelectorSheet.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct CardSelectorSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CreditCard.displayOrder) private var cards: [CreditCard]
    @Binding var selectedCard: CreditCard?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    if cards.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(cards) { card in
                            CardSelectorRow(
                                card: card,
                                isSelected: selectedCard?.id == card.id
                            ) {
                                HapticManager.chipSelect()
                                selectedCard = card
                                dismiss()
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            }
            .background(ReceiptColors.paper(for: colorScheme))
            .navigationTitle("SELECT CARD".letterSpaced)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                    }
                }
            }
            .toolbarBackground(ReceiptColors.paper(for: colorScheme), for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "creditcard")
                .font(.system(size: 48))
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))

            Text("NO CARDS YET".letterSpaced)
                .font(ReceiptTypography.titleMedium)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

            Text("Add cards in the Cards tab")
                .font(ReceiptTypography.bodySmall)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

// MARK: - Card Selector Row
private struct CardSelectorRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let card: CreditCard
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Perforated top edge
                PerforatedEdge()

                HStack(spacing: Spacing.md) {
                    // Card image
                    cardImage

                    // Card info
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        HStack {
                            Text(card.bank.rawValue.uppercased())
                                .font(ReceiptTypography.titleSmall)
                                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                            if let digits = card.lastFourDigits, !digits.isEmpty {
                                Text("•••• \(digits)")
                                    .font(ReceiptTypography.captionLarge)
                                    .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                            }
                        }

                        Text(card.cardName.uppercased())
                            .font(ReceiptTypography.bodySmall)
                            .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                            .lineLimit(1)

                        // Spending progress
                        SpendingContextView(card: card)
                    }

                    Spacer()

                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(ReceiptColors.success)
                    } else {
                        Circle()
                            .stroke(ReceiptColors.inkLight(for: colorScheme), lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(Spacing.md)

                // Perforated bottom edge
                PerforatedEdge()
            }
            .background(ReceiptColors.paperAlt(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(
                        isSelected
                            ? ReceiptColors.ink(for: colorScheme)
                            : ReceiptColors.inkLight(for: colorScheme).opacity(0.3),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(ReceiptButtonStyle())
    }

    @ViewBuilder
    private var cardImage: some View {
        if let imageName = card.imageName, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(card.bank.color.opacity(0.2))
                .frame(width: 48, height: 32)
                .overlay {
                    Text(card.bank.rawValue.prefix(1))
                        .font(ReceiptFont.semibold(14))
                        .foregroundStyle(card.bank.color)
                }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCard: CreditCard?

        var body: some View {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    CardSelectorSheet(selectedCard: $selectedCard)
                }
        }
    }

    return PreviewWrapper()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
