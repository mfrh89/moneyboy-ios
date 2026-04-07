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

    private var incomeSubtotal: Double {
        appViewModel.incomeItems.filter { !$0.excluded }.reduce(0) { $0 + $1.amount }
    }

    private var flexSubtotal: Double {
        appViewModel.flexibleExpenseItems.filter { !$0.excluded }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Hero Section
                Section {
                    if !appViewModel.upcomingSubscriptions.isEmpty {
                        SubscriptionAlertBanner(items: appViewModel.upcomingSubscriptions)
                            .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 3, trailing: 20))
                    }

                    BalanceHeroCard(summary: appViewModel.summary)
                        .listRowInsets(EdgeInsets(top: appViewModel.upcomingSubscriptions.isEmpty ? 20 : 3, leading: 20, bottom: 3, trailing: 20))

                    HStack(spacing: 6) {
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
                    .listRowInsets(EdgeInsets(top: 3, leading: 20, bottom: 20, trailing: 20))
                }
                .listRowSeparator(.hidden)

                // MARK: - Einnahmen
                if !appViewModel.incomeItems.isEmpty {
                    Section {
                        ForEach(appViewModel.incomeItems) { item in
                            Button { editingItem = item } label: {
                                financeItemRow(item)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        sectionHeader("Einnahmen", subtotal: incomeSubtotal)
                    }
                }

                // MARK: - Fixkosten
                if !appViewModel.wohnkostenItems.isEmpty || !appViewModel.fixedExpenseItems.isEmpty {
                    Section {
                        if !appViewModel.wohnkostenItems.isEmpty {
                            Button { selectedTab = .wohnen } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Wohnkosten")
                                        Text("\(appViewModel.wohnkostenItems.count) Posten")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text(wohnkostenTotal.eurFormatted)
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        ForEach(appViewModel.fixedExpenseItems) { item in
                            Button { editingItem = item } label: {
                                financeItemRow(item)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        sectionHeader("Fixkosten", subtotal: fixkostenTotal)
                    }
                }

                // MARK: - Variable Ausgaben
                if !appViewModel.flexibleExpenseItems.isEmpty {
                    Section {
                        ForEach(appViewModel.flexibleExpenseItems) { item in
                            Button { editingItem = item } label: {
                                financeItemRow(item)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        sectionHeader("Variable Ausgaben", subtotal: flexSubtotal)
                    }
                }
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

    // MARK: - Helpers

    private func sectionHeader(_ title: String, subtotal: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "sum")
                    .font(.system(size: 9))
                Text(subtotal.eurFormatted)
            }
        }
    }

    private func financeItemRow(_ item: FinanceItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .foregroundStyle(item.excluded ? .secondary : .primary)
                    .strikethrough(item.excluded)
                Text(item.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.amount.eurFormatted)
                    .foregroundStyle(item.excluded ? .secondary : .primary)
                    .strikethrough(item.excluded)
                if item.isSplit {
                    Text("geteilt")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
