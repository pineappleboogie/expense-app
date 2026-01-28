//
//  Expense.swift
//  MyFirstApp
//

import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var amount: Decimal
    var date: Date
    var label: String?
    var category: ExpenseCategory?
    var bonusCategory: BonusCategory?

    var card: CreditCard?

    init(
        id: UUID = UUID(),
        amount: Decimal,
        date: Date = Date(),
        label: String? = nil,
        category: ExpenseCategory? = nil,
        bonusCategory: BonusCategory? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.label = label
        self.category = category
        self.bonusCategory = bonusCategory
    }
}
