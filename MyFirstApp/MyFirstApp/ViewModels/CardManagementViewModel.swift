//
//  CardManagementViewModel.swift
//  MyFirstApp
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class CardManagementViewModel {
    private let modelContext: ModelContext

    private(set) var cards: [CreditCard] = []
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCards()
    }

    // MARK: - 3.1.1 Fetch all user cards from SwiftData

    func fetchCards() {
        let descriptor = FetchDescriptor<CreditCard>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )

        do {
            cards = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to fetch cards: \(error.localizedDescription)"
            cards = []
        }
    }

    // MARK: - 3.1.2 Add a card from CardTemplate (pre-populated library)

    func addCard(from template: CardTemplate, lastFourDigits: String? = nil, statementDate: Int? = nil) {
        let displayOrder = cards.count
        let card = template.toCreditCard(
            lastFourDigits: lastFourDigits,
            displayOrder: displayOrder,
            statementDate: statementDate
        )

        modelContext.insert(card)
        save()
        fetchCards()
    }

    // MARK: - 3.1.3 Add a custom card with user-defined fields

    func addCustomCard(
        bank: Bank,
        network: CardNetwork,
        cardName: String,
        lastFourDigits: String? = nil,
        cycleType: CycleType = .calendarMonth,
        statementDate: Int? = nil,
        minSpendingThreshold: Decimal? = nil,
        maxSpendingThreshold: Decimal? = nil,
        localEarnRate: Double? = nil,
        foreignEarnRate: Double? = nil,
        baseMilesRate: Double? = nil,
        rewardNotes: String? = nil,
        hasCategoryCaps: Bool = false,
        categoryCaps: [CategoryCapInput] = []
    ) {
        let displayOrder = cards.count

        let card = CreditCard(
            bank: bank,
            network: network,
            cardName: cardName,
            minSpendingThreshold: minSpendingThreshold,
            maxSpendingThreshold: maxSpendingThreshold,
            cycleType: cycleType,
            statementDate: statementDate,
            lastFourDigits: lastFourDigits,
            localEarnRate: localEarnRate,
            foreignEarnRate: foreignEarnRate,
            baseMilesRate: baseMilesRate,
            rewardNotes: rewardNotes,
            hasCategoryCaps: hasCategoryCaps,
            displayOrder: displayOrder
        )

        // Add category caps if provided
        for capInput in categoryCaps {
            let cap = CategoryCap(
                category: capInput.category,
                minSpend: capInput.minSpend,
                capAmount: capInput.capAmount,
                bonusRate: capInput.bonusRate
            )
            card.categoryCaps.append(cap)
        }

        modelContext.insert(card)
        save()
        fetchCards()
    }

    // MARK: - 3.1.4 Update an existing card

    func updateCard(
        _ card: CreditCard,
        bank: Bank? = nil,
        network: CardNetwork? = nil,
        cardName: String? = nil,
        lastFourDigits: String? = nil,
        cycleType: CycleType? = nil,
        statementDate: Int? = nil,
        minSpendingThreshold: Decimal? = nil,
        maxSpendingThreshold: Decimal? = nil,
        localEarnRate: Double? = nil,
        foreignEarnRate: Double? = nil,
        baseMilesRate: Double? = nil,
        rewardNotes: String? = nil,
        hasCategoryCaps: Bool? = nil,
        clearMinThreshold: Bool = false,
        clearMaxThreshold: Bool = false,
        clearStatementDate: Bool = false
    ) {
        if let bank = bank {
            card.bank = bank
        }
        if let network = network {
            card.network = network
        }
        if let cardName = cardName {
            card.cardName = cardName
        }
        if let lastFourDigits = lastFourDigits {
            card.lastFourDigits = lastFourDigits
        }
        if let cycleType = cycleType {
            card.cycleType = cycleType
        }
        if let statementDate = statementDate {
            card.statementDate = statementDate
        }
        if clearStatementDate {
            card.statementDate = nil
        }
        if let minSpendingThreshold = minSpendingThreshold {
            card.minSpendingThreshold = minSpendingThreshold
        }
        if clearMinThreshold {
            card.minSpendingThreshold = nil
        }
        if let maxSpendingThreshold = maxSpendingThreshold {
            card.maxSpendingThreshold = maxSpendingThreshold
        }
        if clearMaxThreshold {
            card.maxSpendingThreshold = nil
        }
        if let localEarnRate = localEarnRate {
            card.localEarnRate = localEarnRate
        }
        if let foreignEarnRate = foreignEarnRate {
            card.foreignEarnRate = foreignEarnRate
        }
        if let baseMilesRate = baseMilesRate {
            card.baseMilesRate = baseMilesRate
        }
        if let rewardNotes = rewardNotes {
            card.rewardNotes = rewardNotes
        }
        if let hasCategoryCaps = hasCategoryCaps {
            card.hasCategoryCaps = hasCategoryCaps
        }

        save()
        fetchCards()
    }

    /// Update category caps for a card (replaces existing caps)
    func updateCategoryCaps(for card: CreditCard, categoryCaps: [CategoryCapInput]) {
        // Remove existing category caps
        for cap in card.categoryCaps {
            modelContext.delete(cap)
        }
        card.categoryCaps.removeAll()

        // Add new category caps
        for capInput in categoryCaps {
            let cap = CategoryCap(
                category: capInput.category,
                minSpend: capInput.minSpend,
                capAmount: capInput.capAmount,
                bonusRate: capInput.bonusRate
            )
            card.categoryCaps.append(cap)
        }

        save()
        fetchCards()
    }

    // MARK: - 3.1.5 Delete a card (with cascade delete of expenses)

    func deleteCard(_ card: CreditCard) {
        modelContext.delete(card)
        save()
        fetchCards()
    }

    // MARK: - 3.1.6 Reorder cards

    func reorderCards(from source: IndexSet, to destination: Int) {
        var reorderedCards = cards
        reorderedCards.move(fromOffsets: source, toOffset: destination)

        // Update display order for all cards
        for (index, card) in reorderedCards.enumerated() {
            card.displayOrder = index
        }

        save()
        fetchCards()
    }

    /// Move a single card to a new position
    func moveCard(_ card: CreditCard, to newIndex: Int) {
        guard let currentIndex = cards.firstIndex(where: { $0.id == card.id }) else { return }
        reorderCards(from: IndexSet(integer: currentIndex), to: newIndex)
    }

    // MARK: - Private Helpers

    private func save() {
        do {
            try modelContext.save()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}

// MARK: - Input Types

/// Input type for creating/updating category caps
struct CategoryCapInput {
    let category: BonusCategory
    let minSpend: Decimal?
    let capAmount: Decimal
    let bonusRate: Double

    init(category: BonusCategory, minSpend: Decimal? = nil, capAmount: Decimal, bonusRate: Double) {
        self.category = category
        self.minSpend = minSpend
        self.capAmount = capAmount
        self.bonusRate = bonusRate
    }
}
