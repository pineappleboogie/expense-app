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
            VStack(spacing: 32) {
                Spacer()

                // Welcome Icon
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                // Welcome Message
                VStack(spacing: 12) {
                    Text("Welcome to MyFirstApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Track your credit card spending to optimize miles earning")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
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
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        showCustomCardForm = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.rectangle")
                            Text("Create Custom Card")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.secondary.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)

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
