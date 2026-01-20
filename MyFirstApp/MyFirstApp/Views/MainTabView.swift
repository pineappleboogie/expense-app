//
//  MainTabView.swift
//  MyFirstApp
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Placeholder for Dashboard
            Text("Dashboard")
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            // Placeholder for Add Expense
            Text("Add Expense")
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }

            // Placeholder for Cards
            Text("Cards")
                .tabItem {
                    Label("Cards", systemImage: "creditcard")
                }
        }
    }
}

#Preview {
    MainTabView()
}
