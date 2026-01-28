//
//  BlockProgressBar.swift
//  MyFirstApp
//

import SwiftUI

struct BlockProgressBar: View {
    @Environment(\.colorScheme) private var colorScheme

    let progress: Double
    let width: Int
    let filledColor: Color?
    let emptyColor: Color?

    init(
        progress: Double,
        width: Int = 10,
        filledColor: Color? = nil,
        emptyColor: Color? = nil
    ) {
        self.progress = progress
        self.width = width
        self.filledColor = filledColor
        self.emptyColor = emptyColor
    }

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<width, id: \.self) { index in
                let isFilled = Double(index) < (min(max(progress, 0), 1) * Double(width))
                Text(isFilled ? BlockProgress.filled : BlockProgress.empty)
                    .font(ReceiptTypography.captionMedium)
                    .foregroundStyle(isFilled ? resolvedFilledColor : resolvedEmptyColor)
            }
        }
    }

    private var resolvedFilledColor: Color {
        filledColor ?? ReceiptColors.ink(for: colorScheme)
    }

    private var resolvedEmptyColor: Color {
        emptyColor ?? ReceiptColors.inkLight(for: colorScheme)
    }
}

// Alternative text-based version
struct BlockProgressText: View {
    let progress: Double
    let width: Int

    init(progress: Double, width: Int = 10) {
        self.progress = progress
        self.width = width
    }

    var body: some View {
        Text(BlockProgress.bar(progress: progress, width: width))
            .font(ReceiptFont.regular(10))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(spacing: 16) {
        BlockProgressBar(progress: 0.3)
        BlockProgressBar(progress: 0.5)
        BlockProgressBar(progress: 0.85, filledColor: .green)
        BlockProgressBar(progress: 1.0, filledColor: .orange)
        BlockProgressBar(progress: 1.2, filledColor: .red)

        Divider()

        BlockProgressText(progress: 0.5)
        BlockProgressText(progress: 0.85, width: 15)
    }
    .padding()
}
