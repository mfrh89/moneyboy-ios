import Foundation
import Combine

@MainActor
class WhatIfViewModel: ObservableObject {
    @Published var overrides: [String: Double] = [:]
    @Published var excludedIDs: Set<String> = []
    @Published var additions: [ScenarioAddition] = []
    @Published var loaded = false

    private let service = ScenarioService()

    var hasChanges: Bool {
        !overrides.isEmpty || !excludedIDs.isEmpty || !additions.isEmpty
    }

    func load() {
        guard !loaded else { return }
        if let data = service.load() {
            overrides = data.overrides
            excludedIDs = Set(data.excluded)
            additions = data.additions
        }
        loaded = true
    }

    func save() {
        let scenario = ScenarioData(
            overrides: overrides,
            excluded: Array(excludedIDs),
            additions: additions
        )
        service.save(scenario.isEmpty ? nil : scenario)
    }

    func reset() {
        overrides = [:]
        excludedIDs = []
        additions = []
        service.save(nil)
    }

    func setOverride(id: String, amount: Double) {
        overrides[id] = amount
    }

    func clearOverride(id: String) {
        overrides.removeValue(forKey: id)
    }

    func toggleExcluded(id: String) {
        if excludedIDs.contains(id) { excludedIDs.remove(id) }
        else { excludedIDs.insert(id) }
    }

    func addScenarioItem(_ item: ScenarioAddition) {
        additions.append(item)
    }

    func removeAddition(at offsets: IndexSet) {
        additions.remove(atOffsets: offsets)
    }

    func scenarioSummary(base: [FinanceItem]) -> FinanceSummary {
        var effectiveItems: [(amount: Double, type: FinanceItem.TransactionType, excluded: Bool)] = base.map { item in
            let amount = overrides[item.id] ?? item.amount
            let excluded = excludedIDs.contains(item.id)
            return (amount, item.type, excluded)
        }
        for addition in additions {
            effectiveItems.append((addition.amount, addition.type, false))
        }

        let income = effectiveItems
            .filter { $0.type == .income && !$0.excluded }
            .reduce(0) { $0 + $1.amount }
        let expenses = effectiveItems
            .filter { $0.type == .expense && !$0.excluded }
            .reduce(0) { $0 + $1.amount }

        return FinanceSummary(totalIncome: income, totalExpenses: expenses, balance: income - expenses)
    }
}
