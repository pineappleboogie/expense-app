//
//  OnboardingView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var cards: [CreditCard]

    @State private var showCardLibrary = false
    @State private var showCustomCardForm = false

    private let decorativeLine = String(repeating: "═", count: 28)

    private let asciiLogo = """
    ╔════════════════════════╗
    ║  EXPENSE  TRACKER      ║
    ║  ────────────────────  ║
    ║  Track • Optimize •    ║
    ║  Earn Miles            ║
    ╚════════════════════════╝
    """

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xxl) {
                Spacer()

                // ASCII Logo
                Text(asciiLogo)
                    .font(ReceiptTypography.bodySmall)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                    .multilineTextAlignment(.center)

                // Welcome Message
                VStack(spacing: Spacing.md) {
                    Text(decorativeLine)
                        .font(ReceiptTypography.captionMedium)
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))

                    Text("W E L C O M E")
                        .font(ReceiptTypography.titleLarge)
                        .foregroundStyle(ReceiptColors.ink(for: colorScheme))

                    Text("Track your credit card spending\nto optimize miles earning")
                        .font(ReceiptTypography.bodyMedium)
                        .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                        .multilineTextAlignment(.center)

                    Text(decorativeLine)
                        .font(ReceiptTypography.captionMedium)
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                }

                Spacer()

                // Action Buttons
                VStack(spacing: Spacing.lg) {
                    Text("ADD YOUR FIRST CARD".letterSpaced)
                        .font(ReceiptTypography.captionMedium)
                        .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                    Button {
                        HapticManager.selection()
                        showCardLibrary = true
                    } label: {
                        Text("[ CHOOSE FROM LIBRARY ]")
                            .font(ReceiptTypography.bodyMedium)
                            .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .background(ReceiptColors.paperAlt(for: colorScheme))
                            .overlay(
                                Rectangle()
                                    .stroke(ReceiptColors.ink(for: colorScheme), lineWidth: 1)
                            )
                    }
                    .buttonStyle(ReceiptButtonStyle())

                    Button {
                        HapticManager.selection()
                        showCustomCardForm = true
                    } label: {
                        Text("[ CREATE CUSTOM CARD ]")
                            .font(ReceiptTypography.bodyMedium)
                            .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.lg)
                            .overlay(
                                Rectangle()
                                    .stroke(
                                        style: StrokeStyle(lineWidth: 1, dash: [4, 2])
                                    )
                                    .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                            )
                    }
                    .buttonStyle(ReceiptButtonStyle())
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()
            }
            .background(ReceiptColors.paper(for: colorScheme))
            .navigationDestination(isPresented: $showCardLibrary) {
                CardLibraryView(isOnboarding: true)
            }
            .navigationDestination(isPresented: $showCustomCardForm) {
                AddCustomCardView(isOnboarding: true)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
