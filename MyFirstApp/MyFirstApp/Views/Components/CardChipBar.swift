//
//  CardChipBar.swift
//  MyFirstApp
//

import SwiftUI

struct CardChipBar: View {
    @Environment(\.colorScheme) private var colorScheme
    let cards: [CreditCard]
    @Binding var selectedCard: CreditCard?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(cards) { card in
                    CardChip(
                        card: card,
                        isSelected: selectedCard?.id == card.id
                    ) {
                        HapticManager.chipSelect()
                        withAnimation(ReceiptAnimation.selection) {
                            selectedCard = card
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Individual Card Chip (Receipt Bracket Style)
struct CardChip: View {
    @Environment(\.colorScheme) private var colorScheme
    let card: CreditCard
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(isSelected ? "[\(chipLabel)]" : chipLabel)
                .font(ReceiptTypography.bodySmall)
                .foregroundStyle(isSelected ?
                    ReceiptColors.ink(for: colorScheme) :
                    ReceiptColors.inkFaded(for: colorScheme))
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    isSelected ?
                    ReceiptColors.paperAlt(for: colorScheme) :
                    Color.clear
                )
                .overlay(
                    Rectangle()
                        .stroke(
                            style: StrokeStyle(lineWidth: 1, dash: isSelected ? [] : [4, 2])
                        )
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                )
        }
        .buttonStyle(ReceiptButtonStyle())
    }

    private var chipLabel: String {
        if let digits = card.lastFourDigits, !digits.isEmpty {
            return "\(card.bank.displayName) \(digits)"
        }
        return card.bank.displayName
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedCard: CreditCard?

        let cards = [
            CreditCard(bank: .dbs, network: .visa, cardName: "Altitude", lastFourDigits: "1234"),
            CreditCard(bank: .uob, network: .visa, cardName: "PRVI Miles", lastFourDigits: "5678"),
            CreditCard(bank: .ocbc, network: .mastercard, cardName: "90N"),
            CreditCard(bank: .citibank, network: .visa, cardName: "Rewards")
        ]

        var body: some View {
            VStack(spacing: 20) {
                CardChipBar(cards: cards, selectedCard: $selectedCard)

                if let card = selectedCard {
                    Text("Selected: \(card.displayName)")
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
