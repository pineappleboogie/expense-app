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
