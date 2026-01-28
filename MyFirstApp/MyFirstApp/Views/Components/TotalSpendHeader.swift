//
//  TotalSpendHeader.swift
//  MyFirstApp
//

import SwiftUI

struct TotalSpendHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let totalSpent: Decimal
    let isCollapsed: Bool
    var monthLabel: String = ""

    private var decorativeLine: String {
        String(repeating: "═", count: 24)
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            if !isCollapsed {
                VStack(spacing: Spacing.xs) {
                    // Top decorative line
                    Text(decorativeLine)
                        .font(ReceiptTypography.captionMedium)
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))

                    // Branding
                    Text("EXPENSE TRACKER".letterSpaced)
                        .font(ReceiptTypography.titleSmall)
                        .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                    // Month label if provided
                    if !monthLabel.isEmpty {
                        Text(monthLabel.uppercased().letterSpaced)
                            .font(ReceiptTypography.captionMedium)
                            .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                    }

                    DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                        .padding(.vertical, Spacing.xs)

                    // Total label
                    Text("T O T A L   S P E N T")
                        .font(ReceiptTypography.titleMedium)
                        .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                    // Amount
                    SpacedAmountText(
                        totalSpent,
                        font: ReceiptTypography.displayMedium,
                        color: ReceiptColors.ink(for: colorScheme)
                    )

                    // Bottom decorative line
                    Text(decorativeLine)
                        .font(ReceiptTypography.captionMedium)
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCollapsed ? 0 : Spacing.lg)
        .animation(ReceiptAnimation.cardCollapse, value: isCollapsed)
    }
}

#Preview {
    VStack(spacing: 32) {
        TotalSpendHeader(totalSpent: 2450.00, isCollapsed: false)
            .background(Color(.systemBackground))

        TotalSpendHeader(totalSpent: 2450.00, isCollapsed: true)
            .background(Color(.systemBackground))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
