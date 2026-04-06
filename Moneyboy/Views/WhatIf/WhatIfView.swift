import SwiftUI

struct WhatIfView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = WhatIfViewModel()
    @State private var showingAddSheet = false

    private var uid: String { authService.user?.uid ?? "" }

    var body: some View {
        NavigationStack {
            List {
                // Comparison card
                comparisonSection

                // Income
                Section("Einnahmen") {
                    ForEach(appViewModel.incomeItems) { item in
                        ScenarioItemRow(
                            item: item,
                            isExcluded: viewModel.excludedIDs.contains(item.id),
                            override: viewModel.overrides[item.id],
                            onExclude: { viewModel.toggleExcluded(id: item.id); viewModel.save(uid: uid) },
                            onOverride: { viewModel.setOverride(id: item.id, amount: $0); viewModel.save(uid: uid) },
                            onClearOverride: { viewModel.clearOverride(id: item.id); viewModel.save(uid: uid) }
                        )
                    }
                }

                // Expenses
                Section("Ausgaben") {
                    ForEach(appViewModel.items.filter { $0.type == .expense }) { item in
                        ScenarioItemRow(
                            item: item,
                            isExcluded: viewModel.excludedIDs.contains(item.id),
                            override: viewModel.overrides[item.id],
                            onExclude: { viewModel.toggleExcluded(id: item.id); viewModel.save(uid: uid) },
                            onOverride: { viewModel.setOverride(id: item.id, amount: $0); viewModel.save(uid: uid) },
                            onClearOverride: { viewModel.clearOverride(id: item.id); viewModel.save(uid: uid) }
                        )
                    }
                }

                // Hypothetical additions
                if !viewModel.additions.isEmpty {
                    Section("Hypothetische Einträge") {
                        ForEach(viewModel.additions) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                    Text(item.category)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text((item.type == .expense ? "-" : "+") + item.amount.eurFormatted)
                                    .foregroundStyle(item.type == .income ? .green : .red)
                            }
                        }
                        .onDelete { viewModel.removeAddition(at: $0); viewModel.save(uid: uid) }
                    }
                }

                // Add hypothetical entry
                Section {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Hypothetischen Eintrag hinzufügen", systemImage: "plus.circle")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Was wäre wenn?")
            .toolbar {
                if viewModel.hasChanges {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Zurücksetzen", role: .destructive) {
                            viewModel.reset(uid: uid)
                        }
                    }
                }
            }
            .task { await viewModel.load(uid: uid) }
            .sheet(isPresented: $showingAddSheet) {
                AddHypotheticalSheet { item in
                    viewModel.addScenarioItem(item)
                    viewModel.save(uid: uid)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var comparisonSection: some View {
        Section {
            let base = appViewModel.summary
            let scenario = viewModel.scenarioSummary(base: appViewModel.items)
            VStack(spacing: 12) {
                Text("Szenario-Vergleich")
                    .font(.headline)
                HStack {
                    comparisonColumn(label: "Aktuell", summary: base, color: .primary)
                    Divider()
                    comparisonColumn(label: "Szenario", summary: scenario, color: .orange)
                }
                let diff = scenario.balance - base.balance
                HStack {
                    Text("Differenz")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text((diff >= 0 ? "+" : "") + diff.eurFormatted)
                        .foregroundStyle(diff >= 0 ? .green : .red)
                        .bold()
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func comparisonColumn(label: String, summary: FinanceSummary, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(summary.balance.eurFormatted)
                .font(.headline)
                .foregroundStyle(color)
            Text("↑ \(summary.totalIncome.eurCompact)")
                .font(.caption)
                .foregroundStyle(.green)
            Text("↓ \(summary.totalExpenses.eurCompact)")
                .font(.caption)
                .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Add Hypothetical Sheet

private struct AddHypotheticalSheet: View {
    let onAdd: (FinanceItem) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var type: FinanceItem.TransactionType = .expense
    @State private var category = "Sonstiges"

    var body: some View {
        NavigationStack {
            Form {
                Section("Typ") {
                    Picker("Typ", selection: $type) {
                        Text("Einnahme").tag(FinanceItem.TransactionType.income)
                        Text("Ausgabe").tag(FinanceItem.TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Details") {
                    TextField("Bezeichnung", text: $title)
                    HStack {
                        TextField("Betrag", text: $amountText)
                            .keyboardType(.decimalPad)
                        Text("€").foregroundStyle(.secondary)
                    }
                    TextField("Kategorie", text: $category)
                }
            }
            .navigationTitle("Hypothetischer Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        let item = FinanceItem(title: title, amount: amount, type: type, category: category)
                        onAdd(item)
                        dismiss()
                    }
                    .disabled(title.isEmpty || amountText.isEmpty)
                }
            }
        }
    }
}
