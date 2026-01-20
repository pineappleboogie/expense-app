//
//  Decimal+Extensions.swift
//  MyFirstApp
//

import Foundation

extension Decimal {
    /// Formats the decimal as SGD currency (e.g., "$1,234.56")
    var formattedAsCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SGD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }

    /// Formats the decimal as a compact currency (e.g., "$1.2k" for $1,234)
    var formattedAsCompactCurrency: String {
        let doubleValue = NSDecimalNumber(decimal: self).doubleValue
        if doubleValue >= 1000 {
            let thousands = doubleValue / 1000
            return String(format: "$%.1fk", thousands)
        }
        return formattedAsCurrency
    }

    /// Formats the decimal as a whole number currency (e.g., "$1,234")
    var formattedAsWholeCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SGD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: self as NSDecimalNumber) ?? "$0"
    }

    /// Calculates progress percentage (0.0 to 1.0+) against a target
    /// Returns 0 if target is nil or zero
    func progressToward(_ target: Decimal?) -> Double {
        guard let target = target, target > 0 else { return 0 }
        let progress = self / target
        return NSDecimalNumber(decimal: progress).doubleValue
    }

    /// Calculates percentage as an integer (0 to 100+)
    func percentageOf(_ total: Decimal?) -> Int {
        guard let total = total, total > 0 else { return 0 }
        let percentage = (self / total) * 100
        return NSDecimalNumber(decimal: percentage).intValue
    }

    /// Returns the decimal clamped to a maximum value
    func clamped(to maximum: Decimal) -> Decimal {
        return min(self, maximum)
    }

    /// Returns the remaining amount to reach a target, or 0 if target is exceeded
    func remaining(to target: Decimal?) -> Decimal {
        guard let target = target else { return 0 }
        let remaining = target - self
        return max(remaining, 0)
    }
}
