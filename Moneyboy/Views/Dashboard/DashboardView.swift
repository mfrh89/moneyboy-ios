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
                    BalanceHeroCard(summary: appViewModel.summary)
                } header: {
                    if !appViewModel.upcomingSubscriptions.isEmpty {
                        SubscriptionAlertBanner(items: appViewModel.upcomingSubscriptions)
                            .textCase(nil)
                            .padding(.bottom, 4)
                    }
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
                            .swipeActions(edge: .trailing) {
                                Button {
                                    appViewModel.toggleExcluded(item)
                                } label: {
                                    Label(item.excluded ? "Show" : "Hide",
                                          systemImage: item.excluded ? "eye" : "eye.slash")
                                }
                                .tint(.orange)
                            }
                        }
                    } header: {
                        sectionHeader("Income", subtotal: incomeSubtotal)
                    }
                    .listSectionSpacing(24)
                }

                // MARK: - Fixkosten
                if !appViewModel.wohnkostenItems.isEmpty || !appViewModel.fixedExpenseItems.isEmpty {
                    Section {
                        if !appViewModel.wohnkostenItems.isEmpty {
                            Button { selectedTab = .wohnen } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Housing Costs")
                                        Text("\(appViewModel.wohnkostenItems.count) items")
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
                            .swipeActions(edge: .trailing) {
                                Button {
                                    appViewModel.toggleExcluded(item)
                                } label: {
                                    Label(item.excluded ? "Show" : "Hide",
                                          systemImage: item.excluded ? "eye" : "eye.slash")
                                }
                                .tint(.orange)
                            }
                        }
                    } header: {
                        sectionHeader("Fixed Costs", subtotal: fixkostenTotal)
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
                            .swipeActions(edge: .trailing) {
                                Button {
                                    appViewModel.toggleExcluded(item)
                                } label: {
                                    Label(item.excluded ? "Show" : "Hide",
                                          systemImage: item.excluded ? "eye" : "eye.slash")
                                }
                                .tint(.orange)
                            }
                        }
                    } header: {
                        sectionHeader("Variable Expenses", subtotal: flexSubtotal)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Overview")
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
                    Text("split")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
