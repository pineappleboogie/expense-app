//
//  AddExpenseSheet.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct AddExpenseSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CreditCard.displayOrder) private var cards: [CreditCard]

    // Form state
    @State private var amountCents: Int = 0
    @State private var noteText = ""
    @State private var selectedCard: CreditCard?
    @State private var selectedCategory: ExpenseCategory?
    @State private var expenseDate = Date()

    // UI state
    @State private var showDatePicker = false
    @State private var showCardSelector = false
    @State private var showCategoryPopover = false
    @State private var isEditingNote = false
    @State private var viewModel: ExpenseViewModel?
    @FocusState private var isNoteFocused: Bool

    // Constants
    private let maxAmountCents = 1_000_000_00 // $1,000,000.00

    private var amountDecimal: Decimal {
        Decimal(amountCents) / 100
    }

    private var amountDisplayText: String {
        let dollars = amountCents / 100
        let cents = amountCents % 100
        return String(format: "$%d.%02d", dollars, cents)
    }

    private var isValid: Bool {
        amountCents > 0 && selectedCard != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button and date
            headerSection

            Spacer()

            // Amount display
            amountSection

            Spacer()

            // Selection pills
            pillsSection
                .padding(.bottom, Spacing.lg)

            // Custom number pad
            CustomNumberPad(
                onDigit: handleDigit,
                onDecimal: handleDecimal,
                onBackspace: handleBackspace
            )

            // Save button
            saveButton
        }
        .background(ReceiptColors.paper(for: colorScheme))
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .sheet(isPresented: $showCardSelector) {
            CardSelectorSheet(selectedCard: $selectedCard)
        }
        .popover(isPresented: $showCategoryPopover, attachmentAnchor: .point(.top)) {
            CategoryPopover(selectedCategory: $selectedCategory) {
                showCategoryPopover = false
            }
            .frame(width: 280)
            .presentationCompactAdaptation(.popover)
        }
        .onAppear {
            setupOnAppear()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Spacer for future left button
            Color.clear
                .frame(width: 44, height: 44)

            Spacer()

            // Title and date (tappable)
            Button {
                HapticManager.selection()
                showDatePicker = true
            } label: {
                VStack(spacing: Spacing.xxs) {
                    Text("ADD EXPENSE".letterSpaced)
                        .font(ReceiptTypography.titleMedium)
                        .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))

                    Text(dateDisplayText)
                        .font(ReceiptTypography.captionLarge)
                        .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
                }
            }
            .buttonStyle(ReceiptButtonStyle())

            Spacer()

            // Close button
            Button {
                HapticManager.lightTap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
    }

    private var dateDisplayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: expenseDate).uppercased()
    }

    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(spacing: Spacing.sm) {
            // Large amount display
            Text(amountDisplayText)
                .font(ReceiptTypography.displayLarge)
                .foregroundStyle(
                    amountCents == 0
                        ? ReceiptColors.inkLight(for: colorScheme)
                        : ReceiptColors.ink(for: colorScheme)
                )
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.1), value: amountCents)

            // Note field (inline)
            if isEditingNote {
                TextField("Add note", text: $noteText)
                    .font(ReceiptTypography.bodyMedium)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .focused($isNoteFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isEditingNote = false
                    }
            } else {
                Button {
                    isEditingNote = true
                    isNoteFocused = true
                } label: {
                    Text(noteText.isEmpty ? "Add note" : noteText)
                        .font(ReceiptTypography.bodyMedium)
                        .foregroundStyle(
                            noteText.isEmpty
                                ? ReceiptColors.inkLight(for: colorScheme)
                                : ReceiptColors.inkFaded(for: colorScheme)
                        )
                }
                .buttonStyle(ReceiptButtonStyle())
            }
        }
        .padding(.horizontal, Spacing.xl)
    }

    // MARK: - Pills Section
    private var pillsSection: some View {
        HStack(spacing: Spacing.md) {
            // Card pill
            Button {
                HapticManager.chipSelect()
                showCardSelector = true
            } label: {
                cardPillContent
            }
            .buttonStyle(PillButtonStyle())

            // Category pill
            Button {
                HapticManager.chipSelect()
                showCategoryPopover = true
            } label: {
                categoryPillContent
            }
            .buttonStyle(PillButtonStyle())
        }
        .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private var cardPillContent: some View {
        HStack(spacing: Spacing.sm) {
            if let card = selectedCard {
                // Card image
                if let imageName = card.imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(card.bank.color.opacity(0.2))
                        .frame(width: 24, height: 16)
                        .overlay {
                            Text(card.bank.rawValue.prefix(1))
                                .font(ReceiptFont.semibold(8))
                                .foregroundStyle(card.bank.color)
                        }
                }

                // Card name
                Text(cardDisplayText(for: card))
                    .font(ReceiptTypography.captionLarge)
                    .foregroundStyle(ReceiptColors.ink(for: colorScheme))
            } else {
                Image(systemName: "creditcard")
                    .font(.system(size: 14))
                    .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))

                Text("Card")
                    .font(ReceiptTypography.captionLarge)
                    .foregroundStyle(ReceiptColors.inkLight(for: colorScheme))
            }
        }
    }

    private func cardDisplayText(for card: CreditCard) -> String {
        if let digits = card.lastFourDigits, !digits.isEmpty {
            return "\(card.bank.rawValue) \(digits)"
        }
        return card.bank.rawValue
    }

    @ViewBuilder
    private var categoryPillContent: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: selectedCategory?.icon ?? "square.grid.2x2")
                .font(.system(size: 14))
                .foregroundStyle(
                    selectedCategory != nil
                        ? ReceiptColors.ink(for: colorScheme)
                        : ReceiptColors.inkLight(for: colorScheme)
                )

            Text(selectedCategory?.displayName ?? "Category")
                .font(ReceiptTypography.captionLarge)
                .foregroundStyle(
                    selectedCategory != nil
                        ? ReceiptColors.ink(for: colorScheme)
                        : ReceiptColors.inkLight(for: colorScheme)
                )
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            saveExpense()
        } label: {
            Text("Save")
                .font(ReceiptFont.medium(18))
                .foregroundStyle(
                    isValid
                        ? ReceiptColors.paper(for: colorScheme)
                        : ReceiptColors.inkLight(for: colorScheme)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    isValid
                        ? ReceiptColors.ink(for: colorScheme)
                        : ReceiptColors.paperAlt(for: colorScheme)
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .disabled(!isValid)
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
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
            .background(ReceiptColors.paper(for: colorScheme))
            .navigationTitle("DATE".letterSpaced)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
            .toolbarBackground(ReceiptColors.paper(for: colorScheme), for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Number Pad Handlers
    private func handleDigit(_ digit: Int) {
        // Calculate new value
        let newValue = amountCents * 10 + digit

        // Check max limit
        if newValue <= maxAmountCents {
            amountCents = newValue
        }
    }

    private func handleDecimal() {
        // For cents-based input, decimal is handled automatically
        // This could be used to shift to cents input mode if needed
    }

    private func handleBackspace() {
        amountCents = amountCents / 10
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
    }

    private func saveExpense() {
        guard let card = selectedCard, amountCents > 0 else { return }

        // Clean up note (nil if empty)
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote: String? = trimmedNote.isEmpty ? nil : trimmedNote

        viewModel?.addExpense(
            amount: amountDecimal,
            card: card,
            date: expenseDate,
            label: finalNote,
            category: selectedCategory,
            bonusCategory: nil
        )

        // Haptic feedback for successful save
        HapticManager.expenseSaved()

        // Dismiss sheet
        dismiss()
    }
}

// MARK: - Pill Button Style
private struct PillButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(ReceiptColors.paperAlt(for: colorScheme))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(ReceiptColors.inkLight(for: colorScheme).opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(ReceiptAnimation.buttonPress, value: configuration.isPressed)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AddExpenseSheet()
        }
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
