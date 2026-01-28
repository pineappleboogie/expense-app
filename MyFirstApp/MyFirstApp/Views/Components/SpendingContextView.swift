//
//  SpendingContextView.swift
//  MyFirstApp
//

import SwiftUI

/// A compact spending progress view for the Add Expense screen
/// Shows current spending progress toward thresholds in a single line with block progress bar
struct SpendingContextView: View {
    @Environment(\.colorScheme) private var colorScheme
    let card: CreditCard

    var body: some View {
        let summary = SpendingCalculator.getCardSpendingSummary(for: card)

        VStack(alignment: .leading, spacing: Spacing.xs) {
            if hasThresholds(card) {
                // Show progress toward min or max threshold
                progressContent(summary: summary)
            } else {
                // No thresholds - show just the current spending
                noThresholdContent(summary: summary)
            }
        }
    }

    @ViewBuilder
    private func progressContent(summary: CardSpendingSummary) -> some View {
        let spent = summary.totalSpending
        let status = summary.thresholdStatus

        // Determine which threshold to show
        if let minThreshold = card.minSpendingThreshold, status == .belowMinimum {
            thresholdRow(
                spent: spent,
                target: minThreshold,
                label: "MIN",
                progress: summary.thresholdProgress.minProgress,
                status: status
            )
        } else if let maxThreshold = card.maxSpendingThreshold {
            thresholdRow(
                spent: spent,
                target: maxThreshold,
                label: "MAX",
                progress: summary.thresholdProgress.maxProgress,
                status: status
            )
        } else if let minThreshold = card.minSpendingThreshold {
            thresholdRow(
                spent: spent,
                target: minThreshold,
                label: "MIN",
                progress: summary.thresholdProgress.minProgress,
                status: status
            )
        }
    }

    private func thresholdRow(
        spent: Decimal,
        target: Decimal,
        label: String,
        progress: Double,
        status: ThresholdStatus
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            // Text row with dot leader
            HStack(spacing: 0) {
                Text("\(spent.formattedAsWholeCurrency) / \(target.formattedAsWholeCurrency) \(label)")
                    .font(ReceiptTypography.captionLarge)
                    .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))
                    .padding(.horizontal, Spacing.xs)

                Text("\(Int(min(progress * 100, 999)))%")
                    .font(ReceiptTypography.captionLarge)
                    .foregroundStyle(progressColor(for: status))
            }

            // Block progress bar
            BlockProgressBar(
                progress: progress,
                width: 15,
                filledColor: progressColor(for: status)
            )
        }
    }

    private func noThresholdContent(summary: CardSpendingSummary) -> some View {
        HStack(spacing: 0) {
            Text("THIS CYCLE")
                .font(ReceiptTypography.captionLarge)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

            DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))
                .padding(.horizontal, Spacing.xs)

            Text(summary.totalSpending.formattedAsCurrency)
                .font(ReceiptTypography.captionLarge)
                .foregroundStyle(ReceiptColors.ink(for: colorScheme))
        }
    }

    private func hasThresholds(_ card: CreditCard) -> Bool {
        card.minSpendingThreshold != nil || card.maxSpendingThreshold != nil
    }

    private func progressColor(for status: ThresholdStatus) -> Color {
        switch status {
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
}

#Preview {
    let card = CreditCard(
        bank: .dbs,
        network: .visa,
        cardName: "Altitude",
        minSpendingThreshold: 500,
        maxSpendingThreshold: 2000,
        lastFourDigits: "1234"
    )

    return VStack(spacing: 20) {
        SpendingContextView(card: card)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
