//
//  CardManagementView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct CardManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.displayOrder) private var cards: [CreditCard]

    @State private var viewModel: CardManagementViewModel?
    @State private var showAddOptions = false
    @State private var showLibrary = false
    @State private var showCustomCard = false
    @State private var cardToEdit: CreditCard?
    @State private var cardToDelete: CreditCard?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                if cards.isEmpty {
                    emptyStateView
                } else {
                    ForEach(cards) { card in
                        CardListRow(card: card)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                cardToEdit = card
                            }
                    }
                    .onDelete(perform: confirmDelete)
                    .onMove(perform: moveCards)
                }
            }
            .navigationTitle("Cards")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .disabled(cards.isEmpty)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showLibrary = true
                        } label: {
                            Label("From Library", systemImage: "square.grid.2x2")
                        }

                        Button {
                            showCustomCard = true
                        } label: {
                            Label("Custom Card", systemImage: "plus.rectangle")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showLibrary) {
                NavigationStack {
                    CardLibraryView(isOnboarding: false)
                }
            }
            .sheet(isPresented: $showCustomCard) {
                NavigationStack {
                    AddCustomCardView(isOnboarding: false)
                }
            }
            .sheet(item: $cardToEdit) { card in
                NavigationStack {
                    EditCardView(card: card)
                }
            }
            .alert("Delete Card", isPresented: $showDeleteConfirmation, presenting: cardToDelete) { card in
                Button("Cancel", role: .cancel) {
                    cardToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    deleteCard(card)
                }
            } message: { card in
                Text("Are you sure you want to delete \(card.displayName)? All associated expenses will also be deleted.")
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = CardManagementViewModel(modelContext: modelContext)
                }
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Cards", systemImage: "creditcard")
        } description: {
            Text("Add a card to start tracking your spending")
        } actions: {
            Menu {
                Button {
                    showLibrary = true
                } label: {
                    Label("From Library", systemImage: "square.grid.2x2")
                }

                Button {
                    showCustomCard = true
                } label: {
                    Label("Custom Card", systemImage: "plus.rectangle")
                }
            } label: {
                Text("Add Card")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        cardToDelete = cards[index]
        showDeleteConfirmation = true
    }

    private func deleteCard(_ card: CreditCard) {
        viewModel?.deleteCard(card)
        cardToDelete = nil
    }

    private func moveCards(from source: IndexSet, to destination: Int) {
        viewModel?.reorderCards(from: source, to: destination)
    }
}

// MARK: - Card List Row

struct CardListRow: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(card.bank.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if card.hasCategoryCaps {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Text(card.displayName)
                .font(.headline)

            // Earn rates
            if card.localEarnRate != nil || card.foreignEarnRate != nil {
                HStack(spacing: 12) {
                    if let local = card.localEarnRate {
                        Label(String(format: "%.1f", local), systemImage: "house")
                    }
                    if let foreign = card.foreignEarnRate {
                        Label(String(format: "%.1f", foreign), systemImage: "airplane")
                    }
                    if let base = card.baseMilesRate {
                        Label(String(format: "%.1f", base), systemImage: "minus.circle")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            // Thresholds
            if card.minSpendingThreshold != nil || card.maxSpendingThreshold != nil {
                HStack(spacing: 12) {
                    if let min = card.minSpendingThreshold {
                        Text("Min: \(min.formattedAsWholeCurrency)")
                    }
                    if let max = card.maxSpendingThreshold {
                        Text("Max: \(max.formattedAsWholeCurrency)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CardManagementView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
