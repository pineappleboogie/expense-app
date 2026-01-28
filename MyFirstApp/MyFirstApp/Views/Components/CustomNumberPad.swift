//
//  CustomNumberPad.swift
//  MyFirstApp
//

import SwiftUI

struct CustomNumberPad: View {
    @Environment(\.colorScheme) private var colorScheme

    let onDigit: (Int) -> Void
    let onDecimal: () -> Void
    let onBackspace: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            // Row 1: 1, 2, 3
            ForEach(1...3, id: \.self) { digit in
                NumberPadButton(label: "\(digit)") {
                    HapticManager.lightTap()
                    onDigit(digit)
                }
            }

            // Row 2: 4, 5, 6
            ForEach(4...6, id: \.self) { digit in
                NumberPadButton(label: "\(digit)") {
                    HapticManager.lightTap()
                    onDigit(digit)
                }
            }

            // Row 3: 7, 8, 9
            ForEach(7...9, id: \.self) { digit in
                NumberPadButton(label: "\(digit)") {
                    HapticManager.lightTap()
                    onDigit(digit)
                }
            }

            // Row 4: ., 0, backspace
            NumberPadButton(label: ".") {
                HapticManager.lightTap()
                onDecimal()
            }

            NumberPadButton(label: "0") {
                HapticManager.lightTap()
                onDigit(0)
            }

            NumberPadButton(systemImage: "delete.left") {
                HapticManager.lightTap()
                onBackspace()
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Number Pad Button
private struct NumberPadButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: String?
    let systemImage: String?
    let action: () -> Void

    init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.systemImage = nil
        self.action = action
    }

    init(systemImage: String, action: @escaping () -> Void) {
        self.label = nil
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if let label = label {
                    Text(label)
                        .font(ReceiptFont.medium(24))
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            .foregroundStyle(ReceiptColors.ink(for: colorScheme))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(ReceiptColors.paperAlt(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(ReceiptColors.inkLight(for: colorScheme).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(NumberPadButtonStyle())
    }
}

// MARK: - Button Style with Press Feedback
private struct NumberPadButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? ReceiptColors.inkLight(for: colorScheme).opacity(0.2)
                    : Color.clear
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(ReceiptAnimation.buttonPress, value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomNumberPad(
            onDigit: { print("Digit: \($0)") },
            onDecimal: { print("Decimal") },
            onBackspace: { print("Backspace") }
        )
    }
    .background(ReceiptColors.paper)
}
