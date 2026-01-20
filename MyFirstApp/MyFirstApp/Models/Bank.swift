//
//  Bank.swift
//  MyFirstApp
//

import Foundation

enum Bank: String, Codable, CaseIterable, Identifiable {
    case dbs = "DBS"
    case uob = "UOB"
    case ocbc = "OCBC"
    case citibank = "Citibank"
    case hsbc = "HSBC"
    case stanChart = "Standard Chartered"
    case amex = "AMEX"
    case maybank = "Maybank"
    case other = "Other"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
