import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Binding var selectedTab: AppTab
    @State private var showingAddSheet = false
    @State private var editingItem: FinanceItem?

    private var fixkostenTotal: Double {
        let wk = appViewModel.wohnkostenItems.filter { !$0.excluded }.reduce(0) { $0 + $1.amount }
        let fk = appViewModel.fixedExpenseItems.filter { !$0.excluded }.reduce(0) { $0 + $1.amount }
        return wk + fk
    }

    private var wohnkostenTotal: Double {
        appViewModel.wohnkostenItems
            .filter { !$0.excluded }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    BalanceHeroCard(summary: appViewModel.summary)

                    if !appViewModel.upcomingSubscriptions.isEmpty {
                        SubscriptionAlertBanner(items: appViewModel.upcomingSubscriptions)
                    }

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
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                LazyVStack(spacing: 0) {
                    TransactionListSection(
                        title: "Einnahmen",
                        items: appViewModel.incomeItems,
                        onTap: { editingItem = $0 },
                        onToggleExcluded: { appViewModel.toggleExcluded($0) }
                    )

                    fixkostenSection

                    TransactionListSection(
                        title: "Variable Ausgaben",
                        items: appViewModel.flexibleExpenseItems,
                        onTap: { editingItem = $0 },
                        onToggleExcluded: { appViewModel.toggleExcluded($0) }
                    )
                }
            }
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

    private var fixkostenSection: some View {
        let hasWohnkosten = !appViewModel.wohnkostenItems.isEmpty
        let hasFixkosten = !appViewModel.fixedExpenseItems.isEmpty

        return Group {
            if hasWohnkosten || hasFixkosten {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Fixkosten")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Spacer()
                        Text(fixkostenTotal.eurFormatted)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        // Wohnkosten summary row
                        if hasWohnkosten {
                            Button { selectedTab = .wohnen } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Wohnkosten")
                                            .font(.body)
                                        Text("\(appViewModel.wohnkostenItems.count) Posten")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text(wohnkostenTotal.eurFormatted)
                                            .font(.body)
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                        }

                        // Regular fixed expenses
                        ForEach(appViewModel.fixedExpenseItems) { item in
                            Button { editingItem = item } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .font(.body)
                                            .foregroundStyle(item.excluded ? .secondary : .primary)
                                            .strikethrough(item.excluded)
                                        Text(item.category)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(item.amount.eurFormatted)
                                        .font(.body)
                                        .strikethrough(item.excluded)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
