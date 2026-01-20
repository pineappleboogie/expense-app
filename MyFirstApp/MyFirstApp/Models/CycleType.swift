//
//  CycleType.swift
//  MyFirstApp
//

import Foundation

enum CycleType: String, Codable, CaseIterable, Identifiable {
    case calendarMonth = "Calendar Month"
    case statementMonth = "Statement Month"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
