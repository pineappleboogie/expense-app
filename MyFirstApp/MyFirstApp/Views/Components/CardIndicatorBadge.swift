//
//  CardIndicatorBadge.swift
//  MyFirstApp
//

import SwiftUI

struct CardIndicatorBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let bankName: String

    var body: some View {
        Text("[\(bankName.uppercased())]")
            .font(ReceiptTypography.captionSmall)
            .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
    }
}

// Extended version with card name - receipt bracket style
struct CardBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let card: CreditCard

    var body: some View {
        Text("[\(card.bank.rawValue.uppercased())]")
            .font(ReceiptTypography.captionSmall)
            .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
    }
}

// Bank color extension
extension Bank {
    var color: Color {
        switch self {
        case .dbs:
            return .red
        case .ocbc:
            return .red
        case .uob:
            return .blue
        case .citibank:
            return .blue
        case .hsbc:
            return .red
        case .stanChart:
            return .green
        case .maybank:
            return .yellow
        case .amex:
            return .blue
        case .other:
            return .gray
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CardIndicatorBadge(bankName: "CITI")
        CardIndicatorBadge(bankName: "DBS")
        CardIndicatorBadge(bankName: "UOB")
    }
    .padding()
}
