import Foundation
import Combine

@MainActor
class WhatIfViewModel: ObservableObject {
    @Published var overrides: [String: Double] = [:]
    @Published var excludedIDs: Set<String> = []
    @Published var additions: [FinanceItem] = []
    @Published var loaded = false

    private let service = ScenarioService()
    private var saveTask: Task<Void, Never>?

    var hasChanges: Bool {
        !overrides.isEmpty || !excludedIDs.isEmpty || !additions.isEmpty
    }

    func load(uid: String) async {
        guard !loaded else { return }
        if let data = try? await service.load(uid: uid) {
            overrides = data.overrides
            excludedIDs = Set(data.excluded)
            additions = data.additions
        }
        loaded = true
    }

    func save(uid: String) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }
            let scenario = ScenarioData(
                overrides: overrides,
                excluded: Array(excludedIDs),
                additions: additions
            )
            try? await service.save(uid: uid, scenario: scenario.isEmpty ? nil : scenario)
        }
    }

    func reset(uid: String) {
        overrides = [:]
        excludedIDs = []
        additions = []
        Task { try? await service.save(uid: uid, scenario: nil) }
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

    func addScenarioItem(_ item: FinanceItem) {
        additions.append(item)
    }

    func removeAddition(at offsets: IndexSet) {
        additions.remove(atOffsets: offsets)
    }

    func scenarioSummary(base: [FinanceItem]) -> FinanceSummary {
        var effective = base.map { item -> FinanceItem in
            var copy = item
            copy.excluded = excludedIDs.contains(item.id)
            if let override = overrides[item.id] { copy.amount = override }
            return copy
        }
        effective += additions
        return .compute(from: effective)
    }
}
