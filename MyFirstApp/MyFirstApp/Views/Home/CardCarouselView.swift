//
//  CardCarouselView.swift
//  MyFirstApp
//

import SwiftUI

struct CardCarouselView: View {
    let cards: [CreditCard]
    let summaries: [UUID: CardSpendingSummary]
    @Binding var selectedCardId: UUID?

    @Namespace private var animation

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(cards) { card in
                        let summary = summaries[card.id]
                        let isSelected = selectedCardId == card.id

                        if isSelected {
                            if let summary = summary {
                                ExpandedCardView(card: card, summary: summary) {
                                    withAnimation(ReceiptAnimation.cardCollapse) {
                                        selectedCardId = nil
                                    }
                                }
                                .matchedGeometryEffect(id: card.id, in: animation)
                                .id(card.id)
                            }
                        } else {
                            if let summary = summary {
                                CompactCardView(card: card, summary: summary) {
                                    withAnimation(ReceiptAnimation.cardExpand) {
                                        selectedCardId = card.id
                                    }
                                }
                                .matchedGeometryEffect(id: card.id, in: animation)
                                .id(card.id)
                                .frame(width: selectedCardId != nil ? ReceiptStyle.peekingCardWidth : nil)
                                .opacity(selectedCardId != nil ? 0.6 : 1.0)
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            .onChange(of: selectedCardId) { _, newValue in
                if let cardId = newValue {
                    withAnimation(ReceiptAnimation.cardExpand) {
                        proxy.scrollTo(cardId, anchor: .center)
                    }
                }
            }
        }
    }
}

// Simplified version without binding for preview
struct CardCarouselPreview: View {
    let cards: [CreditCard]
    let summaries: [UUID: CardSpendingSummary]
    @State private var selectedCardId: UUID?

    var body: some View {
        CardCarouselView(
            cards: cards,
            summaries: summaries,
            selectedCardId: $selectedCardId
        )
    }
}

#Preview {
    let card1 = CreditCard(
        bank: .citibank,
        network: .visa,
        cardName: "Rewards Card",
        maxSpendingThreshold: 1000
    )

    let card2 = CreditCard(
        bank: .dbs,
        network: .mastercard,
        cardName: "Woman's World",
        maxSpendingThreshold: 2000
    )

    let card3 = CreditCard(
        bank: .uob,
        network: .visa,
        cardName: "Preferred Platinum",
        maxSpendingThreshold: 1200
    )

    let summary1 = CardSpendingSummary(
        card: card1,
        dateRange: DateRange(start: Date(), end: Date().addingTimeInterval(86400 * 8)),
        totalSpending: 850,
        thresholdStatus: .inRange,
        thresholdProgress: ThresholdProgress(
            minProgress: 0, maxProgress: 0.85,
            currentSpend: 850, minThreshold: nil, maxThreshold: 1000
        ),
        categoryCapProgress: []
    )

    let summary2 = CardSpendingSummary(
        card: card2,
        dateRange: DateRange(start: Date(), end: Date().addingTimeInterval(86400 * 5)),
        totalSpending: 1200,
        thresholdStatus: .inRange,
        thresholdProgress: ThresholdProgress(
            minProgress: 0, maxProgress: 0.6,
            currentSpend: 1200, minThreshold: nil, maxThreshold: 2000
        ),
        categoryCapProgress: []
    )

    let summary3 = CardSpendingSummary(
        card: card3,
        dateRange: DateRange(start: Date(), end: Date().addingTimeInterval(86400 * 15)),
        totalSpending: 400,
        thresholdStatus: .inRange,
        thresholdProgress: ThresholdProgress(
            minProgress: 0, maxProgress: 0.33,
            currentSpend: 400, minThreshold: nil, maxThreshold: 1200
        ),
        categoryCapProgress: []
    )

    return CardCarouselPreview(
        cards: [card1, card2, card3],
        summaries: [
            card1.id: summary1,
            card2.id: summary2,
            card3.id: summary3
        ]
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}
