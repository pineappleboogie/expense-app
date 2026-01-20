//
//  CardProgressRow.swift
//  MyFirstApp
//

import SwiftUI

struct CardProgressRow: View {
    let summary: CardSpendingSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Bank icon, card name, last 4 digits
            headerSection

            // Current cycle date range
            dateRangeSection

            // Current spending amount
            spendingSection

            // Progress bars (simple or category caps)
            if summary.card.hasCategoryCaps {
                categoryCapProgressSection
            } else {
                simpleProgressSection
            }

            // Earn rates
            earnRatesSection

            // Reward notes
            if let notes = summary.card.rewardNotes, !notes.isEmpty {
                rewardNotesSection(notes)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Bank icon
            Image(systemName: bankIcon)
                .font(.title2)
                .foregroundStyle(bankColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(summary.card.bank.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(summary.card.displayName)
                    .font(.headline)
            }

            Spacer()

            // Status badge
            StatusBadge(status: summary.thresholdStatus)
        }
    }

    // MARK: - Date Range Section
    private var dateRangeSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar.badge.clock")
                .font(.caption)
            Text(summary.dateRange.displayString)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }

    // MARK: - Spending Section
    private var spendingSection: some View {
        Text(summary.totalSpending.formattedAsCurrency)
            .font(.title2)
            .fontWeight(.semibold)
    }

    // MARK: - Simple Progress Section (for cards without category caps)
    private var simpleProgressSection: some View {
        VStack(spacing: 8) {
            // Min threshold progress bar
            if let minThreshold = summary.card.minSpendingThreshold {
                ProgressBarView(
                    progress: summary.thresholdProgress.minProgress,
                    label: "Min: \(summary.totalSpending.formattedAsWholeCurrency) / \(minThreshold.formattedAsWholeCurrency)",
                    colorScheme: .minThreshold(metMin: summary.thresholdProgress.minProgress >= 1.0)
                )
            }

            // Max threshold progress bar
            if let maxThreshold = summary.card.maxSpendingThreshold {
                ProgressBarView(
                    progress: summary.thresholdProgress.maxProgress,
                    label: "Max: \(summary.totalSpending.formattedAsWholeCurrency) / \(maxThreshold.formattedAsWholeCurrency)",
                    colorScheme: .maxThreshold(exceeded: summary.thresholdProgress.maxProgress > 1.0)
                )
            }
        }
    }

    // MARK: - Category Cap Progress Section
    private var categoryCapProgressSection: some View {
        VStack(spacing: 8) {
            ForEach(summary.categoryCapProgress, id: \.category) { capProgress in
                CategoryCapProgressView(progress: capProgress)
            }
        }
    }

    // MARK: - Earn Rates Section
    private var earnRatesSection: some View {
        HStack(spacing: 16) {
            if let localRate = summary.card.localEarnRate {
                earnRateItem(label: "Local", rate: localRate)
            }
            if let foreignRate = summary.card.foreignEarnRate {
                earnRateItem(label: "Foreign", rate: foreignRate)
            }
            if let baseRate = summary.card.baseMilesRate {
                earnRateItem(label: "Base", rate: baseRate)
            }
        }
        .font(.caption)
    }

    private func earnRateItem(label: String, rate: Double) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", rate))
                .fontWeight(.semibold)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Reward Notes Section
    private func rewardNotesSection(_ notes: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "info.circle")
            Text(notes)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    // MARK: - Bank Styling
    private var bankIcon: String {
        switch summary.card.bank {
        case .dbs: return "building.columns.fill"
        case .uob: return "building.2.fill"
        case .ocbc: return "building.fill"
        case .citibank: return "globe"
        case .hsbc: return "hexagon.fill"
        case .stanChart: return "star.fill"
        case .amex: return "creditcard.fill"
        case .maybank: return "m.circle.fill"
        case .other: return "creditcard"
        }
    }

    private var bankColor: Color {
        switch summary.card.bank {
        case .dbs: return .red
        case .uob: return .blue
        case .ocbc: return .red
        case .citibank: return .blue
        case .hsbc: return .red
        case .stanChart: return .green
        case .amex: return .blue
        case .maybank: return .yellow
        case .other: return .gray
        }
    }
}

// MARK: - Category Cap Progress View
struct CategoryCapProgressView: View {
    let progress: CategoryCapProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(progress.category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.1f mpd", progress.bonusRate))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            switch progress.status {
            case .belowMinimum(let spent, let minRequired):
                // Show progress toward minimum unlock
                ProgressBarView(
                    progress: progress.progress,
                    label: "\(spent.formattedAsWholeCurrency) / \(minRequired.formattedAsWholeCurrency) min",
                    colorScheme: .minThreshold(metMin: false)
                )
                Text("Spend \(minRequired.formattedAsWholeCurrency) to unlock bonus rate")
                    .font(.caption2)
                    .foregroundStyle(.orange)

            case .inProgress(let spent, let cap):
                // Show progress toward cap
                ProgressBarView(
                    progress: progress.progress,
                    label: "\(spent.formattedAsWholeCurrency) / \(cap.formattedAsWholeCurrency)",
                    colorScheme: .categoryInProgress
                )

            case .maxedOut(let cap):
                // Maxed out
                ProgressBarView(
                    progress: 1.0,
                    label: "\(cap.formattedAsWholeCurrency) / \(cap.formattedAsWholeCurrency)",
                    colorScheme: .categoryMaxed
                )
                Text("Category maxed out")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    let card = CreditCard(
        bank: .dbs,
        network: .visa,
        cardName: "Altitude Visa Signature",
        minSpendingThreshold: 500,
        maxSpendingThreshold: 2000,
        lastFourDigits: "1234",
        localEarnRate: 1.2,
        foreignEarnRate: 2.0,
        baseMilesRate: 1.2,
        rewardNotes: "3 mpd on online hotels"
    )

    let summary = CardSpendingSummary(
        card: card,
        dateRange: DateRange(start: Date().startOfMonth, end: Date().endOfMonth),
        totalSpending: 750,
        thresholdStatus: .inRange,
        thresholdProgress: ThresholdProgress(
            minProgress: 1.5,
            maxProgress: 0.375,
            currentSpend: 750,
            minThreshold: 500,
            maxThreshold: 2000
        ),
        categoryCapProgress: []
    )

    return CardProgressRow(summary: summary)
        .padding()
        .background(Color(.systemGroupedBackground))
}
