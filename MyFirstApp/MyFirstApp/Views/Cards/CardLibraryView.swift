//
//  CardLibraryView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct CardLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let isOnboarding: Bool

    @State private var selectedTemplate: CardTemplate?
    @State private var showAddCardSheet = false

    init(isOnboarding: Bool = false) {
        self.isOnboarding = isOnboarding
    }

    var body: some View {
        List {
            ForEach(Bank.allCases.filter { bank in
                CardLibrary.cardsByBank[bank]?.isEmpty == false
            }) { bank in
                Section(header: Text(bank.displayName)) {
                    ForEach(CardLibrary.cardsByBank[bank] ?? []) { template in
                        CardTemplateRow(template: template)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTemplate = template
                                showAddCardSheet = true
                            }
                    }
                }
            }
        }
        .navigationTitle("Card Library")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddCardSheet) {
            if let template = selectedTemplate {
                AddCardFromTemplateSheet(
                    template: template,
                    isOnboarding: isOnboarding,
                    onAdd: { lastFourDigits, statementDate in
                        addCard(from: template, lastFourDigits: lastFourDigits, statementDate: statementDate)
                    }
                )
            }
        }
    }

    private func addCard(from template: CardTemplate, lastFourDigits: String?, statementDate: Int?) {
        let viewModel = CardManagementViewModel(modelContext: modelContext)
        viewModel.addCard(from: template, lastFourDigits: lastFourDigits, statementDate: statementDate)
        showAddCardSheet = false
        dismiss()
    }
}

// MARK: - Card Template Row

struct CardTemplateRow: View {
    let template: CardTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.cardName)
                    .font(.headline)

                Spacer()

                if template.hasCategoryCaps {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }

                Image(systemName: template.network.iconName)
                    .foregroundStyle(.secondary)
            }

            // Earn Rates
            if let local = template.localEarnRate, let foreign = template.foreignEarnRate {
                HStack(spacing: 16) {
                    Label("\(formatRate(local)) local", systemImage: "house")
                    Label("\(formatRate(foreign)) foreign", systemImage: "airplane")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            // Reward Notes
            if let notes = template.rewardNotes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }

            // Category Caps indicator
            if template.hasCategoryCaps && !template.categoryCaps.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Has category caps: \(template.categoryCaps.map { $0.category.displayName }.joined(separator: ", "))")
                }
                .font(.caption2)
                .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatRate(_ rate: Double) -> String {
        if rate == rate.rounded() {
            return String(format: "%.0f mpd", rate)
        }
        return String(format: "%.1f mpd", rate)
    }
}

// MARK: - Add Card From Template Sheet

struct AddCardFromTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss

    let template: CardTemplate
    let isOnboarding: Bool
    let onAdd: (String?, Int?) -> Void

    @State private var lastFourDigits: String = ""
    @State private var statementDate: Int = 15
    @State private var useStatementCycle: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Bank")
                        Spacer()
                        Text(template.bank.displayName)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Card Name")
                        Spacer()
                        Text(template.cardName)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Network")
                        Spacer()
                        Text(template.network.displayName)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(header: Text("Earn Rates")) {
                    if let local = template.localEarnRate {
                        HStack {
                            Text("Local")
                            Spacer()
                            Text("\(formatRate(local)) mpd")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let foreign = template.foreignEarnRate {
                        HStack {
                            Text("Foreign")
                            Spacer()
                            Text("\(formatRate(foreign)) mpd")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let base = template.baseMilesRate {
                        HStack {
                            Text("Base")
                            Spacer()
                            Text("\(formatRate(base)) mpd")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let notes = template.rewardNotes {
                    Section(header: Text("Notes")) {
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                }

                if template.hasCategoryCaps && !template.categoryCaps.isEmpty {
                    Section(header: Text("Category Caps")) {
                        ForEach(template.categoryCaps, id: \.category) { cap in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cap.category.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                HStack {
                                    if let minSpend = cap.minSpend {
                                        Text("Min: \(formatCurrency(minSpend))")
                                    }
                                    Text("Cap: \(formatCurrency(cap.capAmount))")
                                    Spacer()
                                    Text("\(formatRate(cap.bonusRate)) mpd")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text("Optional")) {
                    TextField("Last 4 Digits", text: $lastFourDigits)
                        .keyboardType(.numberPad)
                        .onChange(of: lastFourDigits) { _, newValue in
                            // Limit to 4 digits
                            if newValue.count > 4 {
                                lastFourDigits = String(newValue.prefix(4))
                            }
                            // Only allow digits
                            lastFourDigits = newValue.filter { $0.isNumber }
                        }

                    if template.cycleType == .statementMonth {
                        Toggle("Set Statement Date", isOn: $useStatementCycle)

                        if useStatementCycle {
                            Picker("Statement Date", selection: $statementDate) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)").tag(day)
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        let digits = lastFourDigits.isEmpty ? nil : lastFourDigits
                        let statement = (template.cycleType == .statementMonth && useStatementCycle) ? statementDate : nil
                        onAdd(digits, statement)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add Card")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatRate(_ rate: Double) -> String {
        if rate == rate.rounded() {
            return String(format: "%.0f", rate)
        }
        return String(format: "%.1f", rate)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SGD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
    }
}

// MARK: - CardNetwork Extension for Icon

extension CardNetwork {
    var iconName: String {
        switch self {
        case .visa:
            return "v.circle"
        case .mastercard:
            return "m.circle"
        case .amex:
            return "a.circle"
        case .other:
            return "creditcard"
        }
    }
}

#Preview {
    NavigationStack {
        CardLibraryView(isOnboarding: true)
    }
    .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
