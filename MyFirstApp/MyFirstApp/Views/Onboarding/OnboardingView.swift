//
//  OnboardingView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CreditCard]

    @State private var showCardLibrary = false
    @State private var showCustomCardForm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xxl) {
                Spacer()

                // Welcome Icon
                Image(systemName: "creditcard.fill")
                    .font(.system(size: IconSize.xxlarge))
                    .foregroundStyle(Color.appPrimary)

                // Welcome Message
                VStack(spacing: Spacing.md) {
                    Text("Welcome to MyFirstApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Track your credit card spending to optimize miles earning")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xxl)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: Spacing.lg) {
                    Text("Add your first card to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        showCardLibrary = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                            Text("Choose from Library")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(Color.appPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }

                    Button {
                        showCustomCardForm = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.rectangle")
                            Text("Create Custom Card")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(.secondary.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()
            }
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
