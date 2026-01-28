//
//  AddExpenseView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \CreditCard.displayOrder) private var cards: [CreditCard]

    var onSave: (() -> Void)?

    // Form state
    @State private var amountText = ""
    @State private var labelText = ""
    @State private var selectedCard: CreditCard?
    @State private var selectedBonusCategory: BonusCategory?
    @State private var selectedExpenseCategory: ExpenseCategory?
    @State private var expenseDate = Date()
    @State private var viewModel: ExpenseViewModel?

    // UI state
    @State private var isAmountFocused = false
    @State private var isLabelFocused = false
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case amount
        case label
    }

    private var amount: Decimal? {
        Decimal(string: amountText)
    }

    private var isValid: Bool {
        guard let amount = amount, amount > 0, selectedCard != nil else {
            return false
        }
        return true
    }

    private var isKeyboardActive: Bool {
        focusedField != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ReceiptColors.paper(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: Spacing.lg) {
                            // Hero amount section
                            amountSection

                            // Label section
                            labelSection

                            // Content that appears when keyboard is dismissed
                            if !isKeyboardActive {
                                reviewModeContent
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.xl)
                    }
                    .scrollDismissesKeyboard(.interactively)

                    // Save button at bottom (only in review mode)
                    if !isKeyboardActive {
                        saveButtonSection
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ReceiptColors.paper(for: colorScheme), for: .navigationBar)
            .toolbar {
                if isKeyboardActive {
                    ToolbarItemGroup(placement: .keyboard) {
                        keyboardAccessoryContent
                    }
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                categoryPickerSheet
            }
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
            .onAppear {
                setupOnAppear()
            }
            .onChange(of: selectedCard) { _, newCard in
                if newCard?.hasCategoryCaps != true {
                    selectedBonusCategory = nil
                }
            }
        }
    }

    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(spacing: Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(ReceiptTypography.displayLarge)
                    .foregroundStyle(amountText.isEmpty ?
                        ReceiptColors.inkLight(for: colorScheme) :
                        ReceiptColors.ink(for: colorScheme))

                TextField("0.00", text: $amountText)
                    .font(ReceiptTypography.displayLarge)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .focused($focusedField, equals: .amount)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Spacing.md)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = .amount
            }
        }
    }

    // MARK: - Label Section
    private var labelSection: some View {
        TextField("ADD NOTE...", text: $labelText)
            .font(ReceiptTypography.bodyLarge)
            .foregroundStyle(labelText.isEmpty ?
                ReceiptColors.inkLight(for: colorScheme) :
                ReceiptColors.ink(for: colorScheme))
            .focused($focusedField, equals: .label)
            .padding(.bottom, Spacing.md)
    }

    // MARK: - Review Mode Content (when keyboard dismissed)
    private var reviewModeContent: some View {
        VStack(spacing: Spacing.lg) {
            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                .padding(.vertical, Spacing.sm)

            // Card selection chips
            cardChipsSection

            // Spending context (if card selected)
            if let card = selectedCard {
                spendingContextSection(card: card)
            }

            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                .padding(.vertical, Spacing.sm)

            // Category row
            categoryRow

            // Date row
            dateRow

            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))
                .padding(.vertical, Spacing.sm)
        }
    }

    // MARK: - Card Chips Section
    private var cardChipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if !cards.isEmpty {
                CardChipBar(cards: cards, selectedCard: $selectedCard)
            } else {
                Text("NO CARDS ADDED YET".letterSpaced)
                    .font(ReceiptTypography.captionMedium)
                    .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
            }
        }
    }

    // MARK: - Spending Context Section
    private func spendingContextSection(card: CreditCard) -> some View {
        SpendingContextView(card: card)
            .padding(.top, Spacing.xs)
    }

    // MARK: - Category Row
    private var categoryRow: some View {
        Button {
            HapticManager.selection()
            showCategoryPicker = true
        } label: {
            HStack(spacing: 0) {
                Text("CATEGORY")
                    .font(ReceiptTypography.bodyMedium)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))

                DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))
                    .padding(.horizontal, Spacing.xs)

                if let category = selectedExpenseCategory {
                    Text(category.displayName.uppercased())
                        .font(ReceiptTypography.bodyMedium)
                        .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                } else {
                    Text("[NONE]")
                        .font(ReceiptTypography.bodyMedium)
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                }
            }
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(ReceiptButtonStyle())
    }

    // MARK: - Date Row
    private var dateRow: some View {
        Button {
            HapticManager.selection()
            showDatePicker = true
        } label: {
            HStack(spacing: 0) {
                Text("DATE")
                    .font(ReceiptTypography.bodyMedium)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))

                DottedLeader(color: ReceiptColors.inkLight(for: colorScheme))
                    .padding(.horizontal, Spacing.xs)

                Text(dateDisplayText.uppercased())
                    .font(ReceiptTypography.bodyMedium)
                    .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
            }
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(ReceiptButtonStyle())
    }

    private var dateDisplayText: String {
        if Calendar.current.isDateInToday(expenseDate) {
            return "TODAY"
        } else if Calendar.current.isDateInYesterday(expenseDate) {
            return "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: expenseDate).uppercased()
        }
    }

    // MARK: - Keyboard Accessory Content
    private var keyboardAccessoryContent: some View {
        HStack(spacing: Spacing.sm) {
            // Card chips in a horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(cards) { card in
                        CardChip(
                            card: card,
                            isSelected: selectedCard?.id == card.id
                        ) {
                            HapticManager.chipSelect()
                            withAnimation(ReceiptAnimation.selection) {
                                selectedCard = card
                            }
                        }
                    }
                }
            }

            Spacer()

            Button {
                focusedField = nil
            } label: {
                Text("[DONE]")
                    .font(ReceiptTypography.bodySmall)
            }
        }
    }

    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        VStack(spacing: 0) {
            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))

            Button {
                saveExpense()
            } label: {
                Text("[ S A V E ]")
                    .font(ReceiptTypography.titleLarge)
                    .foregroundStyle(isValid ?
                        ReceiptColors.ink(for: colorScheme) :
                        ReceiptColors.inkLight(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg)
                    .background(ReceiptColors.paperAlt(for: colorScheme))
            }
            .disabled(!isValid)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .background(ReceiptColors.paper(for: colorScheme))
    }

    // MARK: - Category Picker Sheet
    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                Button {
                    selectedExpenseCategory = nil
                    showCategoryPicker = false
                } label: {
                    HStack {
                        Text("None")
                        Spacer()
                        if selectedExpenseCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)

                ForEach(ExpenseCategory.allCases) { category in
                    Button {
                        selectedExpenseCategory = category
                        showCategoryPicker = false
                    } label: {
                        HStack {
                            Label(category.displayName, systemImage: category.icon)
                            Spacer()
                            if selectedExpenseCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showCategoryPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Date Picker Sheet
    private var datePickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $expenseDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions
    private func setupOnAppear() {
        if viewModel == nil {
            viewModel = ExpenseViewModel(modelContext: modelContext)
        }
        // Pre-select first card if only one exists
        if selectedCard == nil && cards.count == 1 {
            selectedCard = cards.first
        }
        // Focus amount field on appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            focusedField = .amount
        }
    }

    private func saveExpense() {
        guard let amount = amount, let card = selectedCard else { return }

        // Clean up label (nil if empty)
        let trimmedLabel = labelText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalLabel: String? = trimmedLabel.isEmpty ? nil : trimmedLabel

        viewModel?.addExpense(
            amount: amount,
            card: card,
            date: expenseDate,
            label: finalLabel,
            category: selectedExpenseCategory,
            bonusCategory: selectedBonusCategory
        )

        // Haptic feedback for successful save
        HapticManager.expenseSaved()

        // Reset form silently
        resetForm()
        onSave?()
    }

    private func resetForm() {
        amountText = ""
        labelText = ""
        selectedBonusCategory = nil
        selectedExpenseCategory = nil
        expenseDate = Date()
        // Keep the selected card for convenience
        // Focus amount for next entry
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusedField = .amount
        }
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
