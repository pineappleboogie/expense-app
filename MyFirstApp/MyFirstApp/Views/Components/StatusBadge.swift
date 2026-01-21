//
//  StatusBadge.swift
//  MyFirstApp
//

import SwiftUI

struct StatusBadge: View {
    let status: ThresholdStatus

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background {
            Capsule()
                .fill(backgroundColor)
        }
        .foregroundStyle(foregroundColor)
    }

    private var backgroundColor: Color {
        switch status {
        case .belowMinimum:
            return Color.appWarning.opacity(0.15)
        case .minimumMet, .inRange:
            return Color.appSuccess.opacity(0.15)
        case .overMaximum:
            return Color.appError.opacity(0.15)
        case .noThreshold:
            return Color.gray.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .belowMinimum:
            return Color.appWarning
        case .minimumMet, .inRange:
            return Color.appSuccess
        case .overMaximum:
            return Color.appError
        case .noThreshold:
            return Color.gray
        }
    }
}

#Preview("Light Mode") {
    VStack(spacing: Spacing.lg) {
        StatusBadge(status: .belowMinimum)
        StatusBadge(status: .minimumMet)
        StatusBadge(status: .inRange)
        StatusBadge(status: .overMaximum)
        StatusBadge(status: .noThreshold)
    }
    .padding()
    .background(Color.groupedBackground)
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        StatusBadge(status: .belowMinimum)
        StatusBadge(status: .minimumMet)
        StatusBadge(status: .inRange)
        StatusBadge(status: .overMaximum)
        StatusBadge(status: .noThreshold)
    }
    .padding()
    .background(Color.groupedBackground)
    .preferredColorScheme(.dark)
}
