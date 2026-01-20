//
//  ExpenseCategory.swift
//  MyFirstApp
//

import Foundation

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case dining = "Dining"
    case transport = "Transport"
    case shopping = "Shopping"
    case groceries = "Groceries"
    case online = "Online"
    case travel = "Travel"
    case utilities = "Utilities"
    case others = "Others"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .dining:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .groceries:
            return "cart.fill"
        case .online:
            return "globe"
        case .travel:
            return "airplane"
        case .utilities:
            return "bolt.fill"
        case .others:
            return "ellipsis.circle.fill"
        }
    }
}
