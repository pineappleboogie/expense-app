//
//  CategoryCap.swift
//  MyFirstApp
//

import Foundation
import SwiftData

@Model
final class CategoryCap {
    var id: UUID
    var category: BonusCategory
    var minSpend: Decimal?
    var capAmount: Decimal
    var bonusRate: Double

    var card: CreditCard?

    init(
        id: UUID = UUID(),
        category: BonusCategory,
        minSpend: Decimal? = nil,
        capAmount: Decimal,
        bonusRate: Double
    ) {
        self.id = id
        self.category = category
        self.minSpend = minSpend
        self.capAmount = capAmount
        self.bonusRate = bonusRate
    }
}
