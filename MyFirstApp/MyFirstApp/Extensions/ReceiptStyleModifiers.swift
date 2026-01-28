//
//  ReceiptStyleModifiers.swift
//  MyFirstApp
//

import SwiftUI

// MARK: - Receipt Typography Scale
enum ReceiptTypography {
    // Display - Large amounts, totals
    static let displayLarge = ReceiptFont.semibold(48)  // Hero amounts
    static let displayMedium = ReceiptFont.semibold(32) // Card totals
    static let displaySmall = ReceiptFont.semibold(24)  // Expanded card amounts

    // Title - Section headers
    static let titleLarge = ReceiptFont.medium(14)      // Screen titles
    static let titleMedium = ReceiptFont.medium(12)     // Section headers
    static let titleSmall = ReceiptFont.medium(10)      // Subsection headers

    // Body - Content text
    static let bodyLarge = ReceiptFont.regular(16)      // Transaction labels
    static let bodyMedium = ReceiptFont.regular(14)     // Descriptions
    static let bodySmall = ReceiptFont.regular(12)      // Supporting text

    // Caption - Metadata
    static let captionLarge = ReceiptFont.regular(11)   // Timestamps, hints
    static let captionMedium = ReceiptFont.regular(10)  // Progress labels
    static let captionSmall = ReceiptFont.regular(9)    // Fine print

    // Amount formatting
    static let amountLarge = ReceiptFont.semibold(16)   // Transaction amounts
    static let amountMedium = ReceiptFont.semibold(14)  // Secondary amounts
    static let amountSmall = ReceiptFont.semibold(12)   // Tertiary amounts
}

// MARK: - Letter Spaced Text
struct LetterSpacedText: View {
    let text: String
    let spacing: CGFloat

    init(_ text: String, spacing: CGFloat = ReceiptStyle.headerLetterSpacing) {
        self.text = text
        self.spacing = spacing
    }

    var body: some View {
        Text(spacedText)
            .tracking(0) // Disable default tracking since we're manually spacing
    }

    private var spacedText: String {
        text.uppercased().map { String($0) }.joined(separator: " ")
    }
}

// MARK: - Spaced Amount Text
struct SpacedAmountText: View {
    let amount: Decimal
    let font: Font
    let color: Color

    init(_ amount: Decimal, font: Font = ReceiptFont.semibold(16), color: Color = .primary) {
        self.amount = amount
        self.font = font
        self.color = color
    }

    var body: some View {
        Text(formattedAmount)
            .font(font)
            .foregroundStyle(color)
    }

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        guard let formatted = formatter.string(from: amount as NSDecimalNumber) else {
            return "$0.00"
        }

        // Add spaces between characters for receipt effect
        return formatted.map { String($0) }.joined(separator: " ")
    }
}

// MARK: - Dotted Leader Line
struct DottedLeader: View {
    var color: Color = Color(.tertiaryLabel)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: ReceiptStyle.dividerDotSpacing) {
                ForEach(0..<dotCount(for: geometry.size.width), id: \.self) { _ in
                    Circle()
                        .fill(color)
                        .frame(width: ReceiptStyle.dividerDotSize, height: ReceiptStyle.dividerDotSize)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: ReceiptStyle.dividerDotSize)
    }

    private func dotCount(for width: CGFloat) -> Int {
        Int(width / (ReceiptStyle.dividerDotSize + ReceiptStyle.dividerDotSpacing))
    }
}

// MARK: - Receipt Header Style Modifier
struct ReceiptHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ReceiptFont.medium(12))
            .foregroundStyle(.secondary)
    }
}

// MARK: - Receipt Amount Style Modifier
struct ReceiptAmountStyle: ViewModifier {
    let isLarge: Bool

    init(isLarge: Bool = false) {
        self.isLarge = isLarge
    }

    func body(content: Content) -> some View {
        content
            .font(isLarge ? ReceiptFont.semibold(32) : ReceiptFont.semibold(16))
            .foregroundStyle(.primary)
    }
}

// MARK: - View Extensions
extension View {
    func receiptHeaderStyle() -> some View {
        modifier(ReceiptHeaderStyle())
    }

    func receiptAmountStyle(isLarge: Bool = false) -> some View {
        modifier(ReceiptAmountStyle(isLarge: isLarge))
    }
}

// MARK: - String Extension for Letter Spacing
extension String {
    var letterSpaced: String {
        self.uppercased().map { String($0) }.joined(separator: " ")
    }
}

// MARK: - Block Progress Characters
enum BlockProgress {
    static let filled = "▓"
    static let empty = "░"

    static func bar(progress: Double, width: Int = 10) -> String {
        let filledCount = Int(min(max(progress, 0), 1) * Double(width))
        let emptyCount = width - filledCount
        return String(repeating: filled, count: filledCount) + String(repeating: empty, count: emptyCount)
    }
}

// MARK: - Receipt Paper Background Modifier
struct ReceiptPaperBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(ReceiptColors.paper(for: colorScheme))
    }
}

// MARK: - Receipt Card Style Modifier
struct ReceiptCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let hasPerforation: Bool

    init(hasPerforation: Bool = false) {
        self.hasPerforation = hasPerforation
    }

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if hasPerforation {
                PerforatedEdge()
            }
            content
                .padding(Spacing.md)
            if hasPerforation {
                PerforatedEdge()
            }
        }
        .background(ReceiptColors.paperAlt(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }
}

// MARK: - Perforated Edge
struct PerforatedEdge: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 6) {
                ForEach(0..<Int(geometry.size.width / 10), id: \.self) { _ in
                    Circle()
                        .fill(ReceiptColors.inkLight(for: colorScheme).opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 8)
    }
}

// MARK: - Receipt Button Style
struct ReceiptButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(ReceiptAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Receipt Ink Text Modifier
struct ReceiptInkStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let level: InkLevel

    enum InkLevel {
        case primary, secondary, tertiary
    }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(inkColor)
    }

    private var inkColor: Color {
        switch level {
        case .primary:
            return ReceiptColors.ink(for: colorScheme)
        case .secondary:
            return ReceiptColors.inkFaded(for: colorScheme)
        case .tertiary:
            return ReceiptColors.inkLight(for: colorScheme)
        }
    }
}

// MARK: - View Extensions for Receipt Styles
extension View {
    func receiptPaperBackground() -> some View {
        modifier(ReceiptPaperBackground())
    }

    func receiptCardStyle(hasPerforation: Bool = false) -> some View {
        modifier(ReceiptCardStyle(hasPerforation: hasPerforation))
    }

    func receiptInk(_ level: ReceiptInkStyle.InkLevel = .primary) -> some View {
        modifier(ReceiptInkStyle(level: level))
    }
}
