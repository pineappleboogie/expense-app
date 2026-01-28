//
//  ExpandedCardView.swift
//  MyFirstApp
//

import SwiftUI

struct ExpandedCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let card: CreditCard
    let summary: CardSpendingSummary
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.cardExpand()
            onTap()
        }) {
            VStack(spacing: 0) {
                // Perforated top edge
                PerforatedEdge()

                VStack(spacing: Spacing.md) {
                    // Top Row: Image + Card Info
                    HStack(spacing: Spacing.md) {
                        cardImage

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("\(card.bank.rawValue.uppercased()) \(card.cardName.uppercased())")
                                .font(ReceiptTypography.titleSmall)
                                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                                .lineLimit(1)

                            if let digits = card.lastFourDigits, !digits.isEmpty {
                                Text("•••• \(digits)")
                                    .font(ReceiptTypography.captionLarge)
                                    .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                            }
                        }

                        Spacer()
                    }

                    // Large Amount + Status
                    HStack(alignment: .firstTextBaseline) {
                        SpacedAmountText(
                            summary.totalSpending,
                            font: ReceiptTypography.displaySmall,
                            color: ReceiptColors.ink(for: colorScheme)
                        )

                        Spacer()

                        statusBadge
                    }

                    // Progress Bars
                    progressSection

                    DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                        .padding(.vertical, Spacing.xs)

                    // Cycle Info
                    cycleInfo
                }
                .padding(Spacing.md)

                // Perforated bottom edge
                PerforatedEdge()
            }
            .frame(width: ReceiptStyle.expandedCardWidth)
            .background(ReceiptColors.paperAlt(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
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
                        .font(ReceiptFont.semibold(16))
                        .foregroundStyle(card.bank.color)
                }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text("[\(summary.thresholdStatus.rawValue.uppercased())]")
            .font(ReceiptTypography.captionSmall)
            .foregroundStyle(statusColor)
    }

    @ViewBuilder
    private var progressSection: some View {
        VStack(spacing: Spacing.sm) {
            if let minThreshold = card.minSpendingThreshold {
                progressRow(
                    label: "MIN $\(minThreshold.formatted())",
                    progress: summary.thresholdProgress.minProgress,
                    color: summary.thresholdProgress.minProgress >= 1.0 ? .green : .orange
                )
            }

            if let maxThreshold = card.maxSpendingThreshold {
                progressRow(
                    label: "MAX $\(maxThreshold.formatted())",
                    progress: summary.thresholdProgress.maxProgress,
                    color: summary.thresholdProgress.maxProgress >= 1.0 ? .red : .green
                )
            }

            // Category caps if any
            ForEach(summary.categoryCapProgress, id: \.category) { capProgress in
                progressRow(
                    label: "\(capProgress.category.rawValue.uppercased()) $\(capProgress.capAmount.formatted())",
                    progress: capProgress.progress,
                    color: categoryColor(for: capProgress)
                )
            }
        }
    }

    private func progressRow(label: String, progress: Double, color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(label)
                .font(ReceiptTypography.captionMedium)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                .frame(width: 100, alignment: .leading)

            BlockProgressBar(
                progress: progress,
                width: 12,
                filledColor: color
            )

            Text("\(Int(min(progress, 1.0) * 100))%")
                .font(ReceiptTypography.captionMedium)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                .frame(width: 32, alignment: .trailing)
        }
    }

    private var cycleInfo: some View {
        HStack {
            let daysRemaining = Calendar.current.dateComponents(
                [.day],
                from: Date(),
                to: summary.dateRange.end
            ).day ?? 0

            Text("RESETS IN \(daysRemaining) \(daysRemaining == 1 ? "DAY" : "DAYS")")
                .font(ReceiptTypography.captionMedium)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

            DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))
                .frame(width: 20)

            Text(dateRangeLabel)
                .font(ReceiptTypography.captionMedium)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
        }
    }

    private var dateRangeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let start = formatter.string(from: summary.dateRange.start).uppercased()
        let end = formatter.string(from: summary.dateRange.end).uppercased()

        return "\(start) - \(end)"
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

    private func categoryColor(for capProgress: CategoryCapProgress) -> Color {
        switch capProgress.status {
        case .belowMinimum:
            return ReceiptColors.warning
        case .inProgress:
            return ReceiptColors.success
        case .maxedOut:
            return ReceiptColors.accent
        }
    }
}

#Preview {
    let card = CreditCard(
        bank: .citibank,
        network: .visa,
        cardName: "Rewards Card",
        minSpendingThreshold: 500,
        maxSpendingThreshold: 1000,
        lastFourDigits: "4521"
    )

    let summary = CardSpendingSummary(
        card: card,
        dateRange: DateRange(start: Date(), end: Date().addingTimeInterval(86400 * 8)),
        totalSpending: 850,
        thresholdStatus: .inRange,
        thresholdProgress: ThresholdProgress(
            minProgress: 1.7,
            maxProgress: 0.85,
            currentSpend: 850,
            minThreshold: 500,
            maxThreshold: 1000
        ),
        categoryCapProgress: []
    )

    return ExpandedCardView(card: card, summary: summary) {}
        .padding()
        .background(Color(.systemGroupedBackground))
}
