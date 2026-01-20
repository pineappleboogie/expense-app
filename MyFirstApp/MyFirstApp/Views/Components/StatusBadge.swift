//
//  StatusBadge.swift
//  MyFirstApp
//

import SwiftUI

struct StatusBadge: View {
    let status: ThresholdStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(backgroundColor)
        }
        .foregroundStyle(foregroundColor)
    }

    private var backgroundColor: Color {
        switch status {
        case .belowMinimum:
            return .orange.opacity(0.15)
        case .minimumMet, .inRange:
            return .green.opacity(0.15)
        case .overMaximum:
            return .red.opacity(0.15)
        case .noThreshold:
            return .gray.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .belowMinimum:
            return .orange
        case .minimumMet, .inRange:
            return .green
        case .overMaximum:
            return .red
        case .noThreshold:
            return .gray
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusBadge(status: .belowMinimum)
        StatusBadge(status: .minimumMet)
        StatusBadge(status: .inRange)
        StatusBadge(status: .overMaximum)
        StatusBadge(status: .noThreshold)
    }
    .padding()
}
