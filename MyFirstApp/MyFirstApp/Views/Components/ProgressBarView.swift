//
//  ProgressBarView.swift
//  MyFirstApp
//

import SwiftUI

enum ProgressBarColorScheme {
    case minThreshold(metMin: Bool)
    case maxThreshold(exceeded: Bool)
    case categoryInProgress
    case categoryMaxed

    var trackColor: Color {
        Color(.systemGray5)
    }

    var progressColor: Color {
        switch self {
        case .minThreshold(let metMin):
            return metMin ? .green : .orange
        case .maxThreshold(let exceeded):
            return exceeded ? .red : .blue
        case .categoryInProgress:
            return .green
        case .categoryMaxed:
            return .blue
        }
    }
}

struct ProgressBarView: View {
    let progress: Double
    var label: String?
    var colorScheme: ProgressBarColorScheme = .categoryInProgress
    var height: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let label = label {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(colorScheme.trackColor)

                    // Progress
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(colorScheme.progressColor)
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: height)
        }
    }
}

#Preview("Min Threshold - Not Met") {
    ProgressBarView(
        progress: 0.6,
        label: "Min: $300 / $500",
        colorScheme: .minThreshold(metMin: false)
    )
    .padding()
}

#Preview("Min Threshold - Met") {
    ProgressBarView(
        progress: 1.0,
        label: "Min: $500 / $500",
        colorScheme: .minThreshold(metMin: true)
    )
    .padding()
}

#Preview("Max Threshold - Under") {
    ProgressBarView(
        progress: 0.5,
        label: "Max: $1,000 / $2,000",
        colorScheme: .maxThreshold(exceeded: false)
    )
    .padding()
}

#Preview("Max Threshold - Exceeded") {
    ProgressBarView(
        progress: 1.0,
        label: "Max: $2,100 / $2,000",
        colorScheme: .maxThreshold(exceeded: true)
    )
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: Spacing.lg) {
        ProgressBarView(
            progress: 0.6,
            label: "Min: $300 / $500",
            colorScheme: .minThreshold(metMin: false)
        )
        ProgressBarView(
            progress: 1.0,
            label: "Min: $500 / $500",
            colorScheme: .minThreshold(metMin: true)
        )
        ProgressBarView(
            progress: 0.5,
            label: "Max: $1,000 / $2,000",
            colorScheme: .maxThreshold(exceeded: false)
        )
    }
    .padding()
    .background(Color.cardBackground)
    .preferredColorScheme(.dark)
}
