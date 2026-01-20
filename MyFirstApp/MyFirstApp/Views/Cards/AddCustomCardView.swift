//
//  AddCustomCardView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct AddCustomCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let isOnboarding: Bool

    // Card Basic Info
    @State private var selectedBank: Bank = .dbs
    @State private var selectedNetwork: CardNetwork = .visa
    @State private var cardName: String = ""
    @State private var lastFourDigits: String = ""

    // Cycle Settings
    @State private var cycleType: CycleType = .calendarMonth
    @State private var statementDate: Int = 15

    // Thresholds
    @State private var hasMinThreshold: Bool = false
    @State private var minThresholdString: String = ""
    @State private var hasMaxThreshold: Bool = false
    @State private var maxThresholdString: String = ""

    // Earn Rates
    @State private var localEarnRateString: String = ""
    @State private var foreignEarnRateString: String = ""
    @State private var baseMilesRateString: String = ""

    // Notes
    @State private var rewardNotes: String = ""

    // Category Caps
    @State private var hasCategoryCaps: Bool = false
    @State private var categoryCaps: [EditableCategoryCap] = []

    @State private var showValidationError: Bool = false
    @State private var validationErrorMessage: String = ""

    init(isOnboarding: Bool = false) {
        self.isOnboarding = isOnboarding
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
            Section(header: Text("Spending Thresholds"), footer: Text("Set minimum spend to earn bonus miles, or maximum cap for bonus earning.")) {
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
            Section(header: Text("Earn Rates (Miles per Dollar)"), footer: Text("Leave blank if not applicable.")) {
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
            Section(header: Text("Category Caps"), footer: Text("Enable if this card has per-category spending caps with different bonus rates.")) {
                Toggle("Has Category Caps", isOn: $hasCategoryCaps)
                    .onChange(of: hasCategoryCaps) { _, newValue in
                        if newValue && categoryCaps.isEmpty {
                            // Add a default category cap
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
                    saveCard()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Card")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("Custom Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
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

    private func saveCard() {
        guard isFormValid else {
            validationErrorMessage = "Please enter a card name."
            showValidationError = true
            return
        }

        let viewModel = CardManagementViewModel(modelContext: modelContext)

        // Parse thresholds
        var minThreshold: Decimal? = nil
        var maxThreshold: Decimal? = nil

        if hasMinThreshold, let value = Decimal(string: minThresholdString) {
            minThreshold = value
        }

        if hasMaxThreshold, let value = Decimal(string: maxThresholdString) {
            maxThreshold = value
        }

        // Parse earn rates
        let localRate = Double(localEarnRateString)
        let foreignRate = Double(foreignEarnRateString)
        let baseRate = Double(baseMilesRateString)

        // Parse category caps
        var capInputs: [CategoryCapInput] = []
        if hasCategoryCaps {
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
        }

        viewModel.addCustomCard(
            bank: selectedBank,
            network: selectedNetwork,
            cardName: cardName.trimmingCharacters(in: .whitespaces),
            lastFourDigits: lastFourDigits.isEmpty ? nil : lastFourDigits,
            cycleType: cycleType,
            statementDate: cycleType == .statementMonth ? statementDate : nil,
            minSpendingThreshold: minThreshold,
            maxSpendingThreshold: maxThreshold,
            localEarnRate: localRate,
            foreignEarnRate: foreignRate,
            baseMilesRate: baseRate,
            rewardNotes: rewardNotes.isEmpty ? nil : rewardNotes,
            hasCategoryCaps: hasCategoryCaps,
            categoryCaps: capInputs
        )

        dismiss()
    }
}

// MARK: - Editable Category Cap Model

struct EditableCategoryCap: Identifiable {
    let id = UUID()
    var category: BonusCategory = .online
    var hasMinSpend: Bool = false
    var minSpendString: String = ""
    var capAmountString: String = ""
    var bonusRateString: String = "4.0"
}

// MARK: - Category Cap Edit Row

struct CategoryCapEditRow: View {
    @Binding var cap: EditableCategoryCap

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Category", selection: $cap.category) {
                ForEach(BonusCategory.allCases.filter { $0 != .general }) { category in
                    Text(category.displayName).tag(category)
                }
            }

            Toggle("Has Minimum Spend", isOn: $cap.hasMinSpend)
                .font(.subheadline)

            if cap.hasMinSpend {
                HStack {
                    Text("Min Spend")
                        .font(.subheadline)
                    Spacer()
                    Text("$")
                    TextField("1000", text: $cap.minSpendString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }

            HStack {
                Text("Cap Amount")
                    .font(.subheadline)
                Spacer()
                Text("$")
                TextField("1200", text: $cap.capAmountString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Bonus Rate")
                    .font(.subheadline)
                Spacer()
                TextField("4.0", text: $cap.bonusRateString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                Text("mpd")
                    .foregroundStyle(.secondary)
            }

            Divider()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AddCustomCardView(isOnboarding: true)
    }
    .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
