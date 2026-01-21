//
//  MainTabView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            AddExpenseView(onSave: { selectedTab = 0 })
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(1)

            CardManagementView()
                .tabItem {
                    Label("Cards", systemImage: "creditcard.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
