//
//  ContentView.swift
//  MyFirstApp
//
//  Created by Jian Hong Chen on 23/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var cards: [CreditCard]

    var body: some View {
        if cards.isEmpty {
            OnboardingView()
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
