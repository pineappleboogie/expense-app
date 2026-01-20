//
//  BonusCategory.swift
//  MyFirstApp
//

import Foundation

enum BonusCategory: String, Codable, CaseIterable, Identifiable {
    case online = "Online"
    case contactless = "Contactless"
    case foreignCurrency = "Foreign Currency"
    case dining = "Dining"
    case travel = "Travel"
    case groceries = "Groceries"
    case transport = "Transport"
    case shopping = "Shopping"
    case fuel = "Fuel"
    case general = "General"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
