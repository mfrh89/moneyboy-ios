import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showingAddSheet = false
    @State private var editingItem: FinanceItem?

    var body: some View {
        NavigationStack {
            List {
                // Hero balance card
                Section {
                    BalanceHeroCard(summary: appViewModel.summary)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                // Subscription alerts
                if !appViewModel.upcomingSubscriptions.isEmpty {
                    Section {
                        SubscriptionAlertBanner(items: appViewModel.upcomingSubscriptions)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }

                // Summary tiles
                Section {
                    HStack(spacing: 12) {
                        SummaryTile(
                            title: "Einnahmen",
                            amount: appViewModel.summary.totalIncome,
                            systemImage: "arrow.down.circle.fill",
                            color: .green
                        )
                        SummaryTile(
                            title: "Ausgaben",
                            amount: appViewModel.summary.totalExpenses,
                            systemImage: "arrow.up.circle.fill",
                            color: .red
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Income
                TransactionListSection(
                    title: "Einnahmen",
                    items: appViewModel.incomeItems,
                    onTap: { editingItem = $0 },
                    onToggleExcluded: { item in
                        Task { try? await appViewModel.toggleExcluded(uid: authService.user!.uid, item: item) }
                    }
                )

                // Fixed expenses
                TransactionListSection(
                    title: "Fixkosten",
                    items: appViewModel.fixedExpenseItems,
                    onTap: { editingItem = $0 },
                    onToggleExcluded: { item in
                        Task { try? await appViewModel.toggleExcluded(uid: authService.user!.uid, item: item) }
                    }
                )

                // Variable expenses
                TransactionListSection(
                    title: "Variable Ausgaben",
                    items: appViewModel.flexibleExpenseItems,
                    onTap: { editingItem = $0 },
                    onToggleExcluded: { item in
                        Task { try? await appViewModel.toggleExcluded(uid: authService.user!.uid, item: item) }
                    }
                )
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ItemFormSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingItem) { item in
                ItemFormSheet(existingItem: item)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
