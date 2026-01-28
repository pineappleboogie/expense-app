//
//  CompactCardView.swift
//  MyFirstApp
//

import SwiftUI

struct CompactCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let card: CreditCard
    let summary: CardSpendingSummary
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.cardTap()
            onTap()
        }) {
            VStack(spacing: Spacing.sm) {
                // Card Image
                cardImage

                // Bank abbreviation
                Text(card.bank.rawValue.uppercased())
                    .font(ReceiptTypography.captionSmall)
                    .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                    .lineLimit(1)

                DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                    .frame(width: 60)

                // Spending Amount
                Text(formattedAmount)
                    .font(ReceiptTypography.amountLarge)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                    .lineLimit(1)

                // Progress Bar
                BlockProgressBar(
                    progress: progressValue,
                    width: 8,
                    filledColor: statusColor
                )

                // Reset Label
                Text(resetLabel)
                    .font(ReceiptTypography.captionSmall)
                    .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                    .lineLimit(1)
            }
            .padding(Spacing.sm)
            .frame(width: ReceiptStyle.compactCardWidth, height: ReceiptStyle.compactCardHeight)
            .background(ReceiptColors.paperAlt(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
        }
        .buttonStyle(ReceiptButtonStyle())
    }

    @ViewBuilder
    private var cardImage: some View {
        if let imageName = card.imageName, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(card.bank.color.opacity(0.2))
                .frame(height: 32)
                .overlay {
                    Text(card.bank.rawValue.prefix(1))
                        .font(ReceiptFont.semibold(14))
                        .foregroundStyle(card.bank.color)
                }
        }
    }

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: summary.totalSpending as NSDecimalNumber) ?? "$0"
    }

    private var progressValue: Double {
        // Use max progress if available, otherwise min progress
        if summary.thresholdProgress.maxThreshold != nil {
            return summary.thresholdProgress.maxProgress
        } else if summary.thresholdProgress.minThreshold != nil {
            return summary.thresholdProgress.minProgress
        }
        return 0
    }

    private var statusColor: Color {
        switch summary.thresholdStatus {
        case .belowMinimum:
            return ReceiptColors.warning
        case .minimumMet, .inRange:
            return ReceiptColors.success
        case .overMaximum:
            return ReceiptColors.danger
        case .noThreshold:
            return ReceiptColors.neutral
        }
    }

    private var resetLabel: String {
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
}

#Preview {
    let card = CreditCard(
        bank: .citibank,
        network: .visa,
        cardName: "Rewards Card",
        maxSpendingThreshold: 1000
    )

    let summary = CardSpendingSummary(
        card: card,
        dateRange: DateRange(start: Date(), end: Date().addingTimeInterval(86400 * 8)),
        totalSpending: 850,
        thresholdStatus: .inRange,
        thresholdProgress: ThresholdProgress(
            minProgress: 0,
            maxProgress: 0.85,
            currentSpend: 850,
            minThreshold: nil,
            maxThreshold: 1000
        ),
        categoryCapProgress: []
    )

    return CompactCardView(card: card, summary: summary) {}
        .padding()
        .background(Color(.systemGroupedBackground))
}
