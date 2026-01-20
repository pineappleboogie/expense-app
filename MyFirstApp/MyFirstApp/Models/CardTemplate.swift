//
//  CardTemplate.swift
//  MyFirstApp
//

import Foundation

struct CategoryCapTemplate {
    let category: BonusCategory
    let minSpend: Decimal?
    let capAmount: Decimal
    let bonusRate: Double
}

struct CardTemplate: Identifiable {
    let id = UUID()
    let bank: Bank
    let network: CardNetwork
    let cardName: String
    let localEarnRate: Double?
    let foreignEarnRate: Double?
    let baseMilesRate: Double?
    let rewardNotes: String?
    let hasCategoryCaps: Bool
    let categoryCaps: [CategoryCapTemplate]
    let cycleType: CycleType

    init(
        bank: Bank,
        network: CardNetwork,
        cardName: String,
        localEarnRate: Double? = nil,
        foreignEarnRate: Double? = nil,
        baseMilesRate: Double? = nil,
        rewardNotes: String? = nil,
        hasCategoryCaps: Bool = false,
        categoryCaps: [CategoryCapTemplate] = [],
        cycleType: CycleType = .calendarMonth
    ) {
        self.bank = bank
        self.network = network
        self.cardName = cardName
        self.localEarnRate = localEarnRate
        self.foreignEarnRate = foreignEarnRate
        self.baseMilesRate = baseMilesRate
        self.rewardNotes = rewardNotes
        self.hasCategoryCaps = hasCategoryCaps
        self.categoryCaps = categoryCaps
        self.cycleType = cycleType
    }

    func toCreditCard(lastFourDigits: String? = nil, displayOrder: Int = 0, statementDate: Int? = nil) -> CreditCard {
        let card = CreditCard(
            bank: bank,
            network: network,
            cardName: cardName,
            cycleType: cycleType,
            statementDate: statementDate,
            localEarnRate: localEarnRate,
            foreignEarnRate: foreignEarnRate,
            baseMilesRate: baseMilesRate,
            rewardNotes: rewardNotes,
            hasCategoryCaps: hasCategoryCaps,
            displayOrder: displayOrder
        )
        card.lastFourDigits = lastFourDigits

        for capTemplate in categoryCaps {
            let cap = CategoryCap(
                category: capTemplate.category,
                minSpend: capTemplate.minSpend,
                capAmount: capTemplate.capAmount,
                bonusRate: capTemplate.bonusRate
            )
            card.categoryCaps.append(cap)
        }

        return card
    }
}

struct CardLibrary {
    static let allCards: [CardTemplate] = [
        // MARK: - DBS
        CardTemplate(
            bank: .dbs,
            network: .visa,
            cardName: "Altitude Visa Signature",
            localEarnRate: 1.2,
            foreignEarnRate: 2.0,
            baseMilesRate: 1.2,
            rewardNotes: "3 mpd online hotels"
        ),
        CardTemplate(
            bank: .dbs,
            network: .amex,
            cardName: "Altitude AMEX",
            localEarnRate: 1.2,
            foreignEarnRate: 2.0,
            baseMilesRate: 1.2,
            rewardNotes: "3 mpd online hotels"
        ),
        CardTemplate(
            bank: .dbs,
            network: .mastercard,
            cardName: "Woman's World Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "Capped at $2k/month online"
        ),
        CardTemplate(
            bank: .dbs,
            network: .visa,
            cardName: "yuu Visa",
            localEarnRate: 10.0,
            foreignEarnRate: 0.14,
            baseMilesRate: 0.14,
            rewardNotes: "10 mpd at yuu merchants, $800 min spend, $823 cap"
        ),
        CardTemplate(
            bank: .dbs,
            network: .amex,
            cardName: "yuu AMEX",
            localEarnRate: 10.0,
            foreignEarnRate: 0.14,
            baseMilesRate: 0.14,
            rewardNotes: "10 mpd at yuu merchants, $800 min spend, $823 cap"
        ),

        // MARK: - UOB
        CardTemplate(
            bank: .uob,
            network: .visa,
            cardName: "PRVI Miles Visa",
            localEarnRate: 1.4,
            foreignEarnRate: 2.4,
            baseMilesRate: 1.4,
            rewardNotes: "No cap"
        ),
        CardTemplate(
            bank: .uob,
            network: .mastercard,
            cardName: "PRVI Miles Mastercard",
            localEarnRate: 1.4,
            foreignEarnRate: 2.4,
            baseMilesRate: 1.4,
            rewardNotes: "No cap"
        ),
        CardTemplate(
            bank: .uob,
            network: .visa,
            cardName: "Visa Signature",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "$1k min per category to unlock bonus",
            hasCategoryCaps: true,
            categoryCaps: [
                CategoryCapTemplate(category: .foreignCurrency, minSpend: 1000, capAmount: 1200, bonusRate: 4.0),
                CategoryCapTemplate(category: .contactless, minSpend: 1000, capAmount: 1200, bonusRate: 4.0)
            ],
            cycleType: .statementMonth
        ),
        CardTemplate(
            bank: .uob,
            network: .visa,
            cardName: "Preferred Platinum Visa",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "No minimum per category",
            hasCategoryCaps: true,
            categoryCaps: [
                CategoryCapTemplate(category: .online, minSpend: nil, capAmount: 600, bonusRate: 4.0),
                CategoryCapTemplate(category: .contactless, minSpend: nil, capAmount: 600, bonusRate: 4.0)
            ]
        ),
        CardTemplate(
            bank: .uob,
            network: .visa,
            cardName: "Lady's Solitaire",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "User selects 2 categories, $750 cap each",
            hasCategoryCaps: true,
            categoryCaps: [
                CategoryCapTemplate(category: .shopping, minSpend: nil, capAmount: 750, bonusRate: 4.0),
                CategoryCapTemplate(category: .dining, minSpend: nil, capAmount: 750, bonusRate: 4.0)
            ]
        ),
        CardTemplate(
            bank: .uob,
            network: .mastercard,
            cardName: "Lady's Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "Select 1 category, $1k cap",
            hasCategoryCaps: true,
            categoryCaps: [
                CategoryCapTemplate(category: .shopping, minSpend: nil, capAmount: 1000, bonusRate: 4.0)
            ]
        ),

        // MARK: - OCBC
        CardTemplate(
            bank: .ocbc,
            network: .visa,
            cardName: "90°N Card",
            localEarnRate: 1.3,
            foreignEarnRate: 2.1,
            baseMilesRate: 1.3,
            rewardNotes: "No cap, no expiry"
        ),
        CardTemplate(
            bank: .ocbc,
            network: .visa,
            cardName: "Rewards Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "6 mpd promo on e-commerce"
        ),

        // MARK: - Citibank
        CardTemplate(
            bank: .citibank,
            network: .visa,
            cardName: "Rewards Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "10x on categories",
            cycleType: .statementMonth
        ),
        CardTemplate(
            bank: .citibank,
            network: .visa,
            cardName: "PremierMiles Visa",
            localEarnRate: 1.2,
            foreignEarnRate: 2.0,
            baseMilesRate: 1.2,
            rewardNotes: "Discontinuing Jan 2026"
        ),

        // MARK: - HSBC
        CardTemplate(
            bank: .hsbc,
            network: .visa,
            cardName: "Revolution",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "Online & contactless, $1.5k cap"
        ),
        CardTemplate(
            bank: .hsbc,
            network: .visa,
            cardName: "TravelOne",
            localEarnRate: 1.0,
            foreignEarnRate: 2.5,
            baseMilesRate: 1.0,
            rewardNotes: "No FX fee"
        ),

        // MARK: - Standard Chartered
        CardTemplate(
            bank: .stanChart,
            network: .visa,
            cardName: "Visa Infinite",
            localEarnRate: 1.4,
            foreignEarnRate: 3.0,
            baseMilesRate: 1.4,
            rewardNotes: "$2k min spend"
        ),
        CardTemplate(
            bank: .stanChart,
            network: .visa,
            cardName: "X Card",
            localEarnRate: nil,
            foreignEarnRate: nil,
            baseMilesRate: nil,
            rewardNotes: "Cashback card, not miles"
        ),

        // MARK: - AMEX
        CardTemplate(
            bank: .amex,
            network: .amex,
            cardName: "KrisFlyer Card",
            localEarnRate: 1.1,
            foreignEarnRate: 2.0,
            baseMilesRate: 1.1,
            rewardNotes: "Direct KrisFlyer earn"
        ),
        CardTemplate(
            bank: .amex,
            network: .amex,
            cardName: "Platinum Card",
            localEarnRate: 1.6,
            foreignEarnRate: 1.6,
            baseMilesRate: 1.6,
            rewardNotes: "With MR bonus"
        ),

        // MARK: - Maybank
        CardTemplate(
            bank: .maybank,
            network: .visa,
            cardName: "Horizon Visa Signature",
            localEarnRate: 1.6,
            foreignEarnRate: 3.2,
            baseMilesRate: 1.6,
            rewardNotes: "Good overseas rate"
        ),
        CardTemplate(
            bank: .maybank,
            network: .mastercard,
            cardName: "World Mastercard",
            localEarnRate: 0.4,
            foreignEarnRate: 3.2,
            baseMilesRate: 0.4,
            rewardNotes: "4 mpd petrol, 3.2 mpd FCY with $4k min spend"
        ),
        CardTemplate(
            bank: .maybank,
            network: .visa,
            cardName: "XL Rewards Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "4 mpd dining/shopping/travel/FCY, $500 min, $1k cap, under 40 only"
        )
    ]

    static var cardsByBank: [Bank: [CardTemplate]] {
        Dictionary(grouping: allCards, by: { $0.bank })
    }
}
