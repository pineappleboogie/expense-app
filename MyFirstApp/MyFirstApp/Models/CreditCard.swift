//
//  CreditCard.swift
//  MyFirstApp
//

import Foundation
import SwiftData

@Model
final class CreditCard {
    var id: UUID
    var bank: Bank
    var network: CardNetwork
    var cardName: String
    var minSpendingThreshold: Decimal?
    var maxSpendingThreshold: Decimal?
    var cycleType: CycleType
    var statementDate: Int?
    var lastFourDigits: String?
    var localEarnRate: Double?
    var foreignEarnRate: Double?
    var baseMilesRate: Double?
    var rewardNotes: String?
    var hasCategoryCaps: Bool
    var displayOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \CategoryCap.card)
    var categoryCaps: [CategoryCap]

    @Relationship(deleteRule: .cascade, inverse: \Expense.card)
    var expenses: [Expense]

    init(
        id: UUID = UUID(),
        bank: Bank,
        network: CardNetwork,
        cardName: String,
        minSpendingThreshold: Decimal? = nil,
        maxSpendingThreshold: Decimal? = nil,
        cycleType: CycleType = .calendarMonth,
        statementDate: Int? = nil,
        lastFourDigits: String? = nil,
        localEarnRate: Double? = nil,
        foreignEarnRate: Double? = nil,
        baseMilesRate: Double? = nil,
        rewardNotes: String? = nil,
        hasCategoryCaps: Bool = false,
        displayOrder: Int = 0,
        categoryCaps: [CategoryCap] = [],
        expenses: [Expense] = []
    ) {
        self.id = id
        self.bank = bank
        self.network = network
        self.cardName = cardName
        self.minSpendingThreshold = minSpendingThreshold
        self.maxSpendingThreshold = maxSpendingThreshold
        self.cycleType = cycleType
        self.statementDate = statementDate
        self.lastFourDigits = lastFourDigits
        self.localEarnRate = localEarnRate
        self.foreignEarnRate = foreignEarnRate
        self.baseMilesRate = baseMilesRate
        self.rewardNotes = rewardNotes
        self.hasCategoryCaps = hasCategoryCaps
        self.displayOrder = displayOrder
        self.categoryCaps = categoryCaps
        self.expenses = expenses
    }

    var displayName: String {
        if let digits = lastFourDigits, !digits.isEmpty {
            return "\(cardName) •••• \(digits)"
        }
        return cardName
    }
}
