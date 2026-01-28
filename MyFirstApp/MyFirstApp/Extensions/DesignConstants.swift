//
//  DesignConstants.swift
//  MyFirstApp
//

import SwiftUI

// MARK: - Spacing Constants
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius
enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}

// MARK: - Icon Sizes
enum IconSize {
    static let small: CGFloat = 16
    static let medium: CGFloat = 24
    static let large: CGFloat = 32
    static let xlarge: CGFloat = 48
    static let xxlarge: CGFloat = 80
}

// MARK: - Shadow Styles
struct AppShadow {
    static let card = Shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    // Lighter shadow for dark mode contexts
    static let cardLight = Shadow(color: .black.opacity(0.05), radius: 2, y: 1)

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let y: CGFloat
    }
}

// MARK: - Dark Mode Adaptive Modifier
struct AdaptiveShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .shadow(
                color: colorScheme == .dark ? .clear : AppShadow.card.color,
                radius: AppShadow.card.radius,
                y: AppShadow.card.y
            )
    }
}

extension View {
    func adaptiveShadow() -> some View {
        modifier(AdaptiveShadowModifier())
    }
}

// MARK: - App Colors
extension Color {
    static let appPrimary = Color.blue
    static let appSuccess = Color.green
    static let appWarning = Color.orange
    static let appError = Color.red

    // Background colors that adapt to light/dark mode
    static let cardBackground = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
}

// MARK: - Receipt Color Palette
enum ReceiptColors {
    // Paper backgrounds
    static let paper = Color(red: 0.98, green: 0.97, blue: 0.94)      // Warm cream
    static let paperAlt = Color(red: 0.96, green: 0.94, blue: 0.90)   // Darker cream for cards
    static let paperDark = Color(red: 0.12, green: 0.11, blue: 0.10)  // Dark mode paper
    static let paperDarkAlt = Color(red: 0.16, green: 0.15, blue: 0.14) // Dark mode card

    // Ink colors - light mode
    static let ink = Color(red: 0.15, green: 0.12, blue: 0.10)        // Primary text
    static let inkFaded = Color(red: 0.4, green: 0.37, blue: 0.34)    // Secondary text
    static let inkLight = Color(red: 0.6, green: 0.57, blue: 0.54)    // Tertiary text

    // Ink colors - dark mode (cream tones)
    static let inkDark = Color(red: 0.95, green: 0.93, blue: 0.88)    // Primary text dark
    static let inkDarkFaded = Color(red: 0.75, green: 0.72, blue: 0.68) // Secondary dark
    static let inkDarkLight = Color(red: 0.55, green: 0.52, blue: 0.48) // Tertiary dark

    // Status colors (muted thermal-print style)
    static let success = Color(red: 0.2, green: 0.5, blue: 0.3)       // Muted green
    static let warning = Color(red: 0.7, green: 0.5, blue: 0.2)       // Amber/ochre
    static let danger = Color(red: 0.7, green: 0.25, blue: 0.2)       // Muted red
    static let neutral = Color(red: 0.5, green: 0.48, blue: 0.45)     // Gray

    // Accent for interactive elements
    static let accent = Color(red: 0.2, green: 0.35, blue: 0.55)      // Muted blue

    // Adaptive colors based on color scheme
    static func paper(for scheme: ColorScheme) -> Color {
        scheme == .dark ? paperDark : paper
    }

    static func paperAlt(for scheme: ColorScheme) -> Color {
        scheme == .dark ? paperDarkAlt : paperAlt
    }

    static func ink(for scheme: ColorScheme) -> Color {
        scheme == .dark ? inkDark : ink
    }

    static func inkFaded(for scheme: ColorScheme) -> Color {
        scheme == .dark ? inkDarkFaded : inkFaded
    }

    static func inkLight(for scheme: ColorScheme) -> Color {
        scheme == .dark ? inkDarkLight : inkLight
    }
}

// MARK: - Receipt Animation Presets
enum ReceiptAnimation {
    // Spring animations
    static let cardExpand = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let cardCollapse = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let buttonPress = Animation.spring(response: 0.2, dampingFraction: 0.6)
    static let selection = Animation.spring(response: 0.25, dampingFraction: 0.7)

    // Timing animations
    static let fadeIn = Animation.easeOut(duration: 0.2)
    static let fadeOut = Animation.easeIn(duration: 0.15)
    static let slideIn = Animation.easeOut(duration: 0.25)
}

// MARK: - Receipt Style Constants
enum ReceiptStyle {
    // Typography
    static let amountFontSize: CGFloat = 48
    static let labelFontSize: CGFloat = 17

    // Letter spacing
    static let headerLetterSpacing: CGFloat = 4
    static let amountLetterSpacing: CGFloat = 2

    // Divider
    static let dividerDotSize: CGFloat = 2
    static let dividerDotSpacing: CGFloat = 6

    // Carousel
    static let compactCardWidth: CGFloat = 100
    static let compactCardHeight: CGFloat = 140
    static let expandedCardWidth: CGFloat = 280
    static let peekingCardWidth: CGFloat = 40
}

// MARK: - Fira Code Font
enum ReceiptFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("FiraCode-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("FiraCode-Medium", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("FiraCode-SemiBold", size: size)
    }
}

// MARK: - Dotted Divider View
struct DottedDivider: View {
    var color: Color = Color(.tertiaryLabel)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: ReceiptStyle.dividerDotSpacing) {
                ForEach(0..<Int(geometry.size.width / (ReceiptStyle.dividerDotSize + ReceiptStyle.dividerDotSpacing)), id: \.self) { _ in
                    Circle()
                        .fill(color)
                        .frame(width: ReceiptStyle.dividerDotSize, height: ReceiptStyle.dividerDotSize)
                }
            }
        }
        .frame(height: ReceiptStyle.dividerDotSize)
    }
}
