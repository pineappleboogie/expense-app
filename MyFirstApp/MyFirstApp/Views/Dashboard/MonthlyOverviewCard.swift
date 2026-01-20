//
//  MonthlyOverviewCard.swift
//  MyFirstApp
//

import SwiftUI

struct MonthlyOverviewCard: View {
    let overview: MonthlyOverview

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(overview.monthLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(overview.cardCount) card\(overview.cardCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(overview.totalSpending.formattedAsCurrency)
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Total spending this month")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.opacity(0.1))
        }
    }
}

#Preview {
    MonthlyOverviewCard(overview: MonthlyOverview(
        dateRange: DateRange(start: Date().startOfMonth, end: Date().endOfMonth),
        totalSpending: 1234.56,
        cardCount: 3
    ))
    .padding()
}
