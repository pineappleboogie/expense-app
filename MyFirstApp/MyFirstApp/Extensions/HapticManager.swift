//
//  HapticManager.swift
//  MyFirstApp
//

import UIKit

// MARK: - Haptic Feedback Manager
enum HapticManager {
    // MARK: - Core Haptics

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // MARK: - Receipt-Specific Haptics

    /// Light tap for card selection in carousel
    static func cardTap() {
        impact(.light)
    }

    /// Medium impact for expanding a card
    static func cardExpand() {
        impact(.medium)
    }

    /// Success notification for saving expense
    static func expenseSaved() {
        notification(.success)
    }

    /// Rigid impact for delete swipe
    static func deleteSwipe() {
        impact(.rigid)
    }

    /// Warning for threshold alerts
    static func thresholdWarning() {
        notification(.warning)
    }

    /// Selection feedback for tab changes
    static func tabChange() {
        selection()
    }

    /// Soft impact for chip selection
    static func chipSelect() {
        impact(.soft)
    }

    /// Light impact for pull-to-refresh trigger
    static func refreshTrigger() {
        impact(.light)
    }

    /// Light tap for number pad input
    static func lightTap() {
        impact(.light)
    }
}
