//
//  MainTabView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab = 0
    @State private var showAddExpenseSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 2:
                    CardManagementView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom receipt-style tab bar
            ReceiptTabBar(
                selectedTab: $selectedTab,
                onAddTapped: {
                    showAddExpenseSheet = true
                }
            )
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddExpenseSheet) {
            AddExpenseSheet()
        }
    }
}

// MARK: - Receipt Tab Bar
struct ReceiptTabBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedTab: Int
    var onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Dotted top border
            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))

            // Tab items
            HStack(spacing: 0) {
                ReceiptTabItem(
                    icon: "house",
                    label: "HOME",
                    isSelected: selectedTab == 0
                ) {
                    selectTab(0)
                }

                ReceiptTabItem(
                    icon: "plus",
                    label: "ADD",
                    isSelected: false  // Never shows as selected
                ) {
                    HapticManager.tabChange()
                    onAddTapped()
                }

                ReceiptTabItem(
                    icon: "creditcard",
                    label: "CARDS",
                    isSelected: selectedTab == 2
                ) {
                    selectTab(2)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.md)
        }
        .background(ReceiptColors.paperAlt(for: colorScheme))
    }

    private func selectTab(_ tab: Int) {
        HapticManager.tabChange()
        withAnimation(ReceiptAnimation.selection) {
            selectedTab = tab
        }
    }
}

// MARK: - Receipt Tab Item
struct ReceiptTabItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 20))

                Text(isSelected ? "[\(label)]" : label)
                    .font(ReceiptTypography.captionSmall)
            }
            .foregroundStyle(isSelected ?
                ReceiptColors.ink(for: colorScheme) :
                ReceiptColors.inkLight(for: colorScheme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(ReceiptButtonStyle())
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
