//
//  DashboardView.swift
//  MyFirstApp
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else {
                    contentView
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                if viewModel == nil {
                    viewModel = DashboardViewModel(modelContext: modelContext)
                }
                viewModel?.refresh()
                isLoading = false
            }
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Monthly Overview Card
                if let overview = viewModel?.monthlyOverview {
                    MonthlyOverviewCard(overview: overview)
                        .padding(.horizontal, Spacing.lg)
                }

                // Card Progress List
                if let summaries = viewModel?.cardSummaries, !summaries.isEmpty {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(summaries, id: \.card.id) { summary in
                            CardProgressRow(summary: summary)
                                .padding(.horizontal, Spacing.lg)
                        }
                    }
                } else {
                    emptyStateView
                }
            }
            .padding(.vertical, Spacing.lg)
        }
        .refreshable {
            await refreshData()
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "creditcard")
                .font(.system(size: IconSize.xlarge))
                .foregroundStyle(.secondary)

            Text("No Cards Yet")
                .font(.headline)

            Text("Add a card to start tracking your spending")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, Spacing.lg)
    }

    private func refreshData() async {
        viewModel?.refresh()
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [CreditCard.self, Expense.self, CategoryCap.self], inMemory: true)
}
