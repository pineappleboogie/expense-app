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
    let imageName: String?
    let maxSpendingThreshold: Decimal?

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
        cycleType: CycleType = .calendarMonth,
        imageName: String? = nil,
        maxSpendingThreshold: Decimal? = nil
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
        self.imageName = imageName
        self.maxSpendingThreshold = maxSpendingThreshold
    }

    func toCreditCard(lastFourDigits: String? = nil, displayOrder: Int = 0, statementDate: Int? = nil) -> CreditCard {
        let card = CreditCard(
            bank: bank,
            network: network,
            cardName: cardName,
            maxSpendingThreshold: maxSpendingThreshold,
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
        card.imageName = self.imageName

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
        // MARK: - Citibank
        CardTemplate(
            bank: .citibank,
            network: .visa,
            cardName: "Rewards Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "10x on categories",
            cycleType: .statementMonth,
            imageName: "CitibankRewards",
            maxSpendingThreshold: 1000
        ),

        // MARK: - DBS
        CardTemplate(
            bank: .dbs,
            network: .mastercard,
            cardName: "Woman's World Card",
            localEarnRate: 4.0,
            foreignEarnRate: 4.0,
            baseMilesRate: 0.4,
            rewardNotes: "Capped at $2k/month online",
            imageName: "DBSWomansWorld",
            maxSpendingThreshold: 1000
        ),

        // MARK: - UOB
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
            ],
            imageName: "UOBPreferredPlatinum"
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
            cycleType: .statementMonth,
            imageName: "UOBVisaSignature"
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
            ],
            imageName: "UOBLadysSolitaire"
        )
    ]

    static var cardsByBank: [Bank: [CardTemplate]] {
        Dictionary(grouping: allCards, by: { $0.bank })
    }
}
