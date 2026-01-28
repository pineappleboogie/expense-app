//
//  PreviewData.swift
//  MyFirstApp
//

import Foundation
import SwiftData

enum PreviewData {

    @MainActor
    static let previewContainer: ModelContainer = {
        let schema = Schema([
            CreditCard.self,
            Expense.self,
            CategoryCap.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            insertSampleData(into: container.mainContext)
            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }()

    @MainActor
    static func insertSampleData(into context: ModelContext) {
        // Card 1: DBS Woman's World - high spender with good progress
        let dbsWomansWorld = CreditCard(
            bank: .dbs,
            network: .mastercard,
            cardName: "Woman's World Card",
            minSpendingThreshold: 800,
            maxSpendingThreshold: 2000,
            cycleType: .calendarMonth,
            lastFourDigits: "4521",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "Capped at $2k/month online",
            displayOrder: 0,
            imageName: "DBSWomansWorld"
        )
        context.insert(dbsWomansWorld)

        // Card 2: UOB Preferred Platinum - mid spender with category caps
        let uobPreferred = CreditCard(
            bank: .uob,
            network: .visa,
            cardName: "UOB Preferred Platinum",
            minSpendingThreshold: 500,
            maxSpendingThreshold: 1500,
            cycleType: .statementMonth,
            statementDate: 15,
            lastFourDigits: "8832",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "4 mpd on all spending, capped at $1,500/month",
            hasCategoryCaps: true,
            displayOrder: 1,
            imageName: "UOBPreferredPlatinum"
        )
        context.insert(uobPreferred)

        // Card 3: Citi Rewards - low spender, just starting
        let citiRewards = CreditCard(
            bank: .citibank,
            network: .visa,
            cardName: "Citi Rewards",
            minSpendingThreshold: 300,
            maxSpendingThreshold: 1000,
            cycleType: .calendarMonth,
            lastFourDigits: "1199",
            localEarnRate: 4.0,
            foreignEarnRate: 2.0,
            baseMilesRate: 0.4,
            rewardNotes: "10x points on shopping and online",
            displayOrder: 2,
            imageName: "CitibankRewards"
        )
        context.insert(citiRewards)

        // Generate expenses for the current month
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        // Helper to create a date in the current month
        func dateInCurrentMonth(day: Int) -> Date {
            var components = DateComponents()
            components.year = currentYear
            components.month = currentMonth
            components.day = min(day, 28) // Safe for all months
            return calendar.date(from: components) ?? now
        }

        // DBS Woman's World expenses - $1,250 spent (past minimum, approaching max)
        let dbsExpenses: [(Decimal, String, ExpenseCategory, Int)] = [
            (450.00, "Singapore Airlines Flight", .travel, 3),
            (320.50, "Grab Rides", .transport, 8),
            (185.00, "Cold Storage", .groceries, 12),
            (128.75, "Din Tai Fung", .dining, 15),
            (165.75, "Amazon Shopping", .online, 18)
        ]

        for (amount, label, category, day) in dbsExpenses {
            let expense = Expense(
                amount: amount,
                date: dateInCurrentMonth(day: day),
                label: label,
                category: category
            )
            expense.card = dbsWomansWorld
            context.insert(expense)
        }

        // UOB Preferred Platinum expenses - $680 spent (past minimum)
        let uobExpenses: [(Decimal, String, ExpenseCategory, Int)] = [
            (250.00, "NTUC Fairprice", .groceries, 5),
            (180.00, "Uniqlo", .shopping, 10),
            (95.50, "Starbucks & Lunch", .dining, 14),
            (154.50, "Shell Petrol", .transport, 20)
        ]

        for (amount, label, category, day) in uobExpenses {
            let expense = Expense(
                amount: amount,
                date: dateInCurrentMonth(day: day),
                label: label,
                category: category
            )
            expense.card = uobPreferred
            context.insert(expense)
        }

        // Citi Rewards expenses - $150 spent (not yet at minimum)
        let citiExpenses: [(Decimal, String, ExpenseCategory, Int)] = [
            (89.90, "Lazada Order", .online, 7),
            (60.10, "Watsons", .shopping, 16)
        ]

        for (amount, label, category, day) in citiExpenses {
            let expense = Expense(
                amount: amount,
                date: dateInCurrentMonth(day: day),
                label: label,
                category: category
            )
            expense.card = citiRewards
            context.insert(expense)
        }

        // Save the context to persist data
        try? context.save()
    }
}
