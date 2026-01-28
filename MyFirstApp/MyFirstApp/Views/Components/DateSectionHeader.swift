//
//  DateSectionHeader.swift
//  MyFirstApp
//

import SwiftUI

struct DateSectionHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let dateLabel: String
    let totalAmount: Decimal

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(dateLabel.letterSpaced)
                .font(ReceiptTypography.titleMedium)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

            DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))

            Text(totalAmount.formattedAsCurrency)
                .font(ReceiptTypography.bodySmall)
                .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
        }
        .padding(.vertical, Spacing.sm)
    }
}

// Helper to format dates as receipt-style labels
extension Date {
    var receiptDateLabel: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "TODAY"
        } else if calendar.isDateInYesterday(self) {
            return "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: self).uppercased()
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        DateSectionHeader(dateLabel: "TODAY", totalAmount: 169.30)
        DateSectionHeader(dateLabel: "YESTERDAY", totalAmount: 119.90)
        DateSectionHeader(dateLabel: "JAN 24", totalAmount: 45.00)
    }
    .padding()
}
