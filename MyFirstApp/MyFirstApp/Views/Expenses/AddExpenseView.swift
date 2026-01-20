//
//  AddExpenseView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.displayOrder) private var cards: [CreditCard]

    var onSave: (() -> Void)?

    @State private var amountText = ""
    @State private var selectedCard: CreditCard?
    @State private var selectedBonusCategory: BonusCategory?
    @State private var selectedExpenseCategory: ExpenseCategory?
    @State private var expenseDate = Date()
    @State private var showingSuccessAlert = false
    @State private var viewModel: ExpenseViewModel?

    private var amount: Decimal? {
        Decimal(string: amountText)
    }

    private var isValid: Bool {
        guard let amount = amount, amount > 0, selectedCard != nil else {
            return false
        }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                // Amount Section
                Section {
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }
                } header: {
                    Text("Amount")
                }

                // Card Selection
                Section {
                    Picker("Card", selection: $selectedCard) {
                        Text("Select a card").tag(nil as CreditCard?)
                        ForEach(cards) { card in
                            Text(card.displayName)
                                .tag(card as CreditCard?)
                        }
                    }
                } header: {
                    Text("Card")
                }

                // Bonus Category (only if selected card has category caps)
                if let card = selectedCard, card.hasCategoryCaps {
                    Section {
                        Picker("Bonus Category", selection: $selectedBonusCategory) {
                            Text("General").tag(nil as BonusCategory?)
                            ForEach(card.categoryCaps, id: \.category) { cap in
                                Text(cap.category.displayName).tag(cap.category as BonusCategory?)
                            }
                        }
                    } header: {
                        Text("Bonus Category")
                    } footer: {
                        Text("Select the bonus category to track spending toward caps")
                    }
                }

                // Date Section
                Section {
                    DatePicker("Date", selection: $expenseDate, displayedComponents: .date)
                } header: {
                    Text("Date")
                }

                // Expense Category (optional)
                Section {
                    Picker("Category", selection: $selectedExpenseCategory) {
                        Text("None").tag(nil as ExpenseCategory?)
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category as ExpenseCategory?)
                        }
                    }
                } header: {
                    Text("Category (Optional)")
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Expense Saved", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    onSave?()
                }
            } message: {
                Text("Your expense has been recorded")
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ExpenseViewModel(modelContext: modelContext)
                }
                // Pre-select first card if only one exists
                if selectedCard == nil && cards.count == 1 {
                    selectedCard = cards.first
                }
            }
            .onChange(of: selectedCard) { _, newCard in
                // Reset bonus category when card changes
                if newCard?.hasCategoryCaps != true {
                    selectedBonusCategory = nil
                }
            }
        }
    }

    private func saveExpense() {
        guard let amount = amount, let card = selectedCard else { return }

        viewModel?.addExpense(
            amount: amount,
            card: card,
            date: expenseDate,
            category: selectedExpenseCategory,
            bonusCategory: selectedBonusCategory
        )

        // Reset form
        resetForm()
        showingSuccessAlert = true
    }

    private func resetForm() {
        amountText = ""
        selectedBonusCategory = nil
        selectedExpenseCategory = nil
        expenseDate = Date()
        // Keep the selected card for convenience
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
