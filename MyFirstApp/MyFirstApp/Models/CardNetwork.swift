//
//  CardNetwork.swift
//  MyFirstApp
//

import Foundation

enum CardNetwork: String, Codable, CaseIterable, Identifiable {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case amex = "AMEX"
    case other = "Other"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
