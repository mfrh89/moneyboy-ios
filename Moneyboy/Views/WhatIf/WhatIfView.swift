import SwiftUI

struct WhatIfView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = WhatIfViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                comparisonSection

                Section("Income") {
                    ForEach(appViewModel.incomeItems) { item in
                        ScenarioItemRow(
                            item: item,
                            isExcluded: viewModel.excludedIDs.contains(item.id),
                            override: viewModel.overrides[item.id],
                            onExclude: { viewModel.toggleExcluded(id: item.id); viewModel.save() },
                            onOverride: { viewModel.setOverride(id: item.id, amount: $0); viewModel.save() },
                            onClearOverride: { viewModel.clearOverride(id: item.id); viewModel.save() }
                        )
                    }
                }

                Section("Expenses") {
                    ForEach(appViewModel.items.filter { $0.type == .expense }.sorted { $0.amount > $1.amount }) { item in
                        ScenarioItemRow(
                            item: item,
                            isExcluded: viewModel.excludedIDs.contains(item.id),
                            override: viewModel.overrides[item.id],
                            onExclude: { viewModel.toggleExcluded(id: item.id); viewModel.save() },
                            onOverride: { viewModel.setOverride(id: item.id, amount: $0); viewModel.save() },
                            onClearOverride: { viewModel.clearOverride(id: item.id); viewModel.save() }
                        )
                    }
                }

                if !viewModel.additions.isEmpty {
                    Section("Hypothetical Entries") {
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
                            }
                        }
                        .onDelete { viewModel.removeAddition(at: $0); viewModel.save() }
                    }
                }

                Section {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Hypothetical Entry", systemImage: "plus.circle")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("What If?")
            .toolbar {
                if viewModel.hasChanges {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Reset", role: .destructive) {
                            viewModel.reset()
                        }
                    }
                }
            }
            .onAppear { viewModel.load() }
            .sheet(isPresented: $showingAddSheet) {
                AddHypotheticalSheet { item in
                    viewModel.addScenarioItem(item)
                    viewModel.save()
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
                Text("Scenario Comparison")
                    .font(.headline)
                HStack {
                    comparisonColumn(label: "Current", summary: base)
                    Divider()
                    comparisonColumn(label: "Scenario", summary: scenario)
                }
                let diff = scenario.balance - base.balance
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Difference")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text((diff >= 0 ? "+" : "") + diff.eurFormatted)
                            .font(.headline)
                            .bold()
                            .foregroundStyle(diff >= 0 ? .green : .red)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func comparisonColumn(label: String, summary: FinanceSummary) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(summary.balance.eurFormatted)
                .font(.headline)
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
    let onAdd: (ScenarioAddition) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var type: FinanceItem.TransactionType = .expense
    @State private var category = "Other"

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $type) {
                        Text("Income").tag(FinanceItem.TransactionType.income)
                        Text("Expense").tag(FinanceItem.TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Details") {
                    TextField("Title", text: $title)
                    HStack {
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                        Text("€").foregroundStyle(.secondary)
                    }
                    TextField("Category", text: $category)
                }
            }
            .navigationTitle("Hypothetical Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        let item = ScenarioAddition(title: title, amount: amount, type: type, category: category)
                        onAdd(item)
                        dismiss()
                    }
                    .disabled(title.isEmpty || amountText.isEmpty)
                }
            }
        }
    }
}
