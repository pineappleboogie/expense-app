//
//  DashboardView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Monthly Overview Card
                    if let overview = viewModel?.monthlyOverview {
                        MonthlyOverviewCard(overview: overview)
                            .padding(.horizontal)
                    }

                    // Card Progress List
                    if let summaries = viewModel?.cardSummaries, !summaries.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(summaries, id: \.card.id) { summary in
                                CardProgressRow(summary: summary)
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        emptyStateView
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await refreshData()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                if viewModel == nil {
                    viewModel = DashboardViewModel(modelContext: modelContext)
                }
                viewModel?.refresh()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Cards Yet")
                .font(.headline)

            Text("Add a card to start tracking your spending")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
    }

    private func refreshData() async {
        viewModel?.refresh()
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
