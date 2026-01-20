//
//  EditCardView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct EditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let card: CreditCard

    // Card Basic Info
    @State private var selectedBank: Bank
    @State private var selectedNetwork: CardNetwork
    @State private var cardName: String
    @State private var lastFourDigits: String

    // Cycle Settings
    @State private var cycleType: CycleType
    @State private var statementDate: Int

    // Thresholds
    @State private var hasMinThreshold: Bool
    @State private var minThresholdString: String
    @State private var hasMaxThreshold: Bool
    @State private var maxThresholdString: String

    // Earn Rates
    @State private var localEarnRateString: String
    @State private var foreignEarnRateString: String
    @State private var baseMilesRateString: String

    // Notes
    @State private var rewardNotes: String

    // Category Caps
    @State private var hasCategoryCaps: Bool
    @State private var categoryCaps: [EditableCategoryCap]

    // Alerts
    @State private var showDeleteConfirmation = false
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""

    init(card: CreditCard) {
        self.card = card

        _selectedBank = State(initialValue: card.bank)
        _selectedNetwork = State(initialValue: card.network)
        _cardName = State(initialValue: card.cardName)
        _lastFourDigits = State(initialValue: card.lastFourDigits ?? "")

        _cycleType = State(initialValue: card.cycleType)
        _statementDate = State(initialValue: card.statementDate ?? 15)

        _hasMinThreshold = State(initialValue: card.minSpendingThreshold != nil)
        _minThresholdString = State(initialValue: card.minSpendingThreshold.map { "\($0)" } ?? "")
        _hasMaxThreshold = State(initialValue: card.maxSpendingThreshold != nil)
        _maxThresholdString = State(initialValue: card.maxSpendingThreshold.map { "\($0)" } ?? "")

        _localEarnRateString = State(initialValue: card.localEarnRate.map { String($0) } ?? "")
        _foreignEarnRateString = State(initialValue: card.foreignEarnRate.map { String($0) } ?? "")
        _baseMilesRateString = State(initialValue: card.baseMilesRate.map { String($0) } ?? "")

        _rewardNotes = State(initialValue: card.rewardNotes ?? "")

        _hasCategoryCaps = State(initialValue: card.hasCategoryCaps)
        _categoryCaps = State(initialValue: card.categoryCaps.map { cap in
            EditableCategoryCap(
                category: cap.category,
                hasMinSpend: cap.minSpend != nil,
                minSpendString: cap.minSpend.map { "\($0)" } ?? "",
                capAmountString: "\(cap.capAmount)",
                bonusRateString: String(cap.bonusRate)
            )
        })
    }

    var body: some View {
        Form {
            // MARK: - Basic Info
            Section(header: Text("Card Details")) {
                Picker("Bank", selection: $selectedBank) {
                    ForEach(Bank.allCases) { bank in
                        Text(bank.displayName).tag(bank)
                    }
                }

                Picker("Network", selection: $selectedNetwork) {
                    ForEach(CardNetwork.allCases) { network in
                        Text(network.displayName).tag(network)
                    }
                }

                TextField("Card Name", text: $cardName)

                TextField("Last 4 Digits (Optional)", text: $lastFourDigits)
                    .keyboardType(.numberPad)
                    .onChange(of: lastFourDigits) { _, newValue in
                        if newValue.count > 4 {
                            lastFourDigits = String(newValue.prefix(4))
                        }
                        lastFourDigits = newValue.filter { $0.isNumber }
                    }
            }

            // MARK: - Cycle Settings
            Section(header: Text("Billing Cycle")) {
                Picker("Cycle Type", selection: $cycleType) {
                    Text("Calendar Month").tag(CycleType.calendarMonth)
                    Text("Statement Month").tag(CycleType.statementMonth)
                }

                if cycleType == .statementMonth {
                    Picker("Statement Date", selection: $statementDate) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                }
            }

            // MARK: - Thresholds
            Section(header: Text("Spending Thresholds")) {
                Toggle("Has Minimum Spend", isOn: $hasMinThreshold)

                if hasMinThreshold {
                    HStack {
                        Text("$")
                        TextField("Minimum", text: $minThresholdString)
                            .keyboardType(.decimalPad)
                    }
                }

                Toggle("Has Maximum Cap", isOn: $hasMaxThreshold)

                if hasMaxThreshold {
                    HStack {
                        Text("$")
                        TextField("Maximum", text: $maxThresholdString)
                            .keyboardType(.decimalPad)
                    }
                }
            }

            // MARK: - Earn Rates
            Section(header: Text("Earn Rates (Miles per Dollar)")) {
                HStack {
                    Text("Local")
                    Spacer()
                    TextField("e.g. 1.4", text: $localEarnRateString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("mpd")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Foreign")
                    Spacer()
                    TextField("e.g. 2.4", text: $foreignEarnRateString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("mpd")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Base")
                    Spacer()
                    TextField("e.g. 0.4", text: $baseMilesRateString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("mpd")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Reward Notes
            Section(header: Text("Additional Notes")) {
                TextField("Reward notes (Optional)", text: $rewardNotes, axis: .vertical)
                    .lineLimit(3...6)
            }

            // MARK: - Category Caps
            Section(header: Text("Category Caps")) {
                Toggle("Has Category Caps", isOn: $hasCategoryCaps)
                    .onChange(of: hasCategoryCaps) { _, newValue in
                        if newValue && categoryCaps.isEmpty {
                            categoryCaps.append(EditableCategoryCap())
                        }
                    }
            }

            if hasCategoryCaps {
                Section(header: Text("Category Cap Details")) {
                    ForEach($categoryCaps) { $cap in
                        CategoryCapEditRow(cap: $cap)
                    }
                    .onDelete { indexSet in
                        categoryCaps.remove(atOffsets: indexSet)
                    }

                    Button {
                        categoryCaps.append(EditableCategoryCap())
                    } label: {
                        Label("Add Category Cap", systemImage: "plus.circle")
                    }
                }
            }

            // MARK: - Save Button
            Section {
                Button {
                    saveChanges()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Changes")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(!isFormValid)
            }

            // MARK: - Delete Button
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Card")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Edit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Delete Card", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCard()
            }
        } message: {
            Text("Are you sure you want to delete this card? All associated expenses will also be deleted.")
        }
        .alert("Validation Error", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationErrorMessage)
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !cardName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Save

    private func saveChanges() {
        guard isFormValid else {
            validationErrorMessage = "Please enter a card name."
            showValidationError = true
            return
        }

        let viewModel = CardManagementViewModel(modelContext: modelContext)

        // Update basic info
        viewModel.updateCard(
            card,
            bank: selectedBank,
            network: selectedNetwork,
            cardName: cardName.trimmingCharacters(in: .whitespaces),
            lastFourDigits: lastFourDigits.isEmpty ? nil : lastFourDigits,
            cycleType: cycleType,
            statementDate: cycleType == .statementMonth ? statementDate : nil,
            minSpendingThreshold: hasMinThreshold ? Decimal(string: minThresholdString) : nil,
            maxSpendingThreshold: hasMaxThreshold ? Decimal(string: maxThresholdString) : nil,
            localEarnRate: Double(localEarnRateString),
            foreignEarnRate: Double(foreignEarnRateString),
            baseMilesRate: Double(baseMilesRateString),
            rewardNotes: rewardNotes.isEmpty ? nil : rewardNotes,
            hasCategoryCaps: hasCategoryCaps,
            clearMinThreshold: !hasMinThreshold,
            clearMaxThreshold: !hasMaxThreshold,
            clearStatementDate: cycleType != .statementMonth
        )

        // Update category caps if enabled
        if hasCategoryCaps {
            var capInputs: [CategoryCapInput] = []
            for cap in categoryCaps {
                guard let capAmount = Decimal(string: cap.capAmountString) else { continue }
                let bonusRate = Double(cap.bonusRateString) ?? 4.0
                var minSpend: Decimal? = nil
                if cap.hasMinSpend, let minValue = Decimal(string: cap.minSpendString) {
                    minSpend = minValue
                }
                capInputs.append(CategoryCapInput(
                    category: cap.category,
                    minSpend: minSpend,
                    capAmount: capAmount,
                    bonusRate: bonusRate
                ))
            }
            viewModel.updateCategoryCaps(for: card, categoryCaps: capInputs)
        } else {
            // Clear category caps if disabled
            viewModel.updateCategoryCaps(for: card, categoryCaps: [])
        }

        dismiss()
    }

    // MARK: - Delete

    private func deleteCard() {
        let viewModel = CardManagementViewModel(modelContext: modelContext)
        viewModel.deleteCard(card)
        dismiss()
    }
}


#Preview {
    let card = CreditCard(
        bank: .dbs,
        network: .visa,
        cardName: "Altitude Visa Signature",
        minSpendingThreshold: 500,
        maxSpendingThreshold: 2000,
        lastFourDigits: "1234",
        localEarnRate: 1.2,
        foreignEarnRate: 2.0,
        baseMilesRate: 1.2,
        rewardNotes: "3 mpd on online hotels"
    )

    return NavigationStack {
        EditCardView(card: card)
    }
    .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
