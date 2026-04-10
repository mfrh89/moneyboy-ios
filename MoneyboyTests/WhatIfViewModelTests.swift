import Testing
import SwiftData
@testable import Moneyboy

@Suite("WhatIfViewModel")
struct WhatIfViewModelTests {

    private func makeItem(
        id: String = "item-1",
        title: String = "Test",
        amount: Double,
        type: FinanceItem.TransactionType
    ) -> FinanceItem {
        FinanceItem(
            id: id,
            title: title,
            amount: amount,
            type: type,
            category: "Other"
        )
    }

    // MARK: - hasChanges

    @Test @MainActor func hasChangesDefaultFalse() {
        let vm = WhatIfViewModel()
        #expect(vm.hasChanges == false)
    }

    @Test @MainActor func hasChangesAfterOverride() {
        let vm = WhatIfViewModel()
        vm.setOverride(id: "item-1", amount: 500)
        #expect(vm.hasChanges == true)
    }

    @Test @MainActor func hasChangesAfterExclude() {
        let vm = WhatIfViewModel()
        vm.toggleExcluded(id: "item-1")
        #expect(vm.hasChanges == true)
    }

    @Test @MainActor func hasChangesAfterAddition() {
        let vm = WhatIfViewModel()
        vm.addScenarioItem(ScenarioAddition(title: "New", amount: 100, type: .expense, category: "Other"))
        #expect(vm.hasChanges == true)
    }

    // MARK: - Override logic

    @Test @MainActor func setAndClearOverride() {
        let vm = WhatIfViewModel()
        vm.setOverride(id: "item-1", amount: 999)
        #expect(vm.overrides["item-1"] == 999)
        vm.clearOverride(id: "item-1")
        #expect(vm.overrides["item-1"] == nil)
    }

    // MARK: - Exclude logic

    @Test @MainActor func toggleExcludedTwiceRemoves() {
        let vm = WhatIfViewModel()
        vm.toggleExcluded(id: "item-1")
        #expect(vm.excludedIDs.contains("item-1"))
        vm.toggleExcluded(id: "item-1")
        #expect(!vm.excludedIDs.contains("item-1"))
    }

    // MARK: - Reset

    @Test @MainActor func resetClearsAll() {
        let vm = WhatIfViewModel()
        vm.setOverride(id: "item-1", amount: 500)
        vm.toggleExcluded(id: "item-2")
        vm.addScenarioItem(ScenarioAddition(title: "New", amount: 100, type: .expense, category: "Other"))
        vm.reset()
        #expect(vm.overrides.isEmpty)
        #expect(vm.excludedIDs.isEmpty)
        #expect(vm.additions.isEmpty)
        #expect(vm.hasChanges == false)
    }

    // MARK: - scenarioSummary

    @Test @MainActor func scenarioSummaryWithNoChanges() {
        let vm = WhatIfViewModel()
        let items = [
            makeItem(id: "1", amount: 3000, type: .income),
            makeItem(id: "2", amount: 800, type: .expense)
        ]
        let summary = vm.scenarioSummary(base: items)
        #expect(summary.totalIncome == 3000)
        #expect(summary.totalExpenses == 800)
        #expect(summary.balance == 2200)
    }

    @Test @MainActor func scenarioSummaryWithOverride() {
        let vm = WhatIfViewModel()
        vm.setOverride(id: "1", amount: 4000)
        let items = [
            makeItem(id: "1", amount: 3000, type: .income),
            makeItem(id: "2", amount: 800, type: .expense)
        ]
        let summary = vm.scenarioSummary(base: items)
        #expect(summary.totalIncome == 4000)
        #expect(summary.totalExpenses == 800)
        #expect(summary.balance == 3200)
    }

    @Test @MainActor func scenarioSummaryWithExcludedItem() {
        let vm = WhatIfViewModel()
        vm.toggleExcluded(id: "2")
        let items = [
            makeItem(id: "1", amount: 3000, type: .income),
            makeItem(id: "2", amount: 800, type: .expense)
        ]
        let summary = vm.scenarioSummary(base: items)
        #expect(summary.totalIncome == 3000)
        #expect(summary.totalExpenses == 0)
        #expect(summary.balance == 3000)
    }

    @Test @MainActor func scenarioSummaryWithAddition() {
        let vm = WhatIfViewModel()
        vm.addScenarioItem(ScenarioAddition(title: "Freelance", amount: 1000, type: .income, category: "Side Income"))
        let items = [
            makeItem(id: "1", amount: 3000, type: .income)
        ]
        let summary = vm.scenarioSummary(base: items)
        #expect(summary.totalIncome == 4000)
        #expect(summary.balance == 4000)
    }

    @Test @MainActor func scenarioSummaryCombined() {
        let vm = WhatIfViewModel()
        vm.setOverride(id: "1", amount: 3500)       // raise income
        vm.toggleExcluded(id: "3")                    // exclude an expense
        vm.addScenarioItem(ScenarioAddition(title: "Gym", amount: 50, type: .expense, category: "Health"))
        let items = [
            makeItem(id: "1", amount: 3000, type: .income),
            makeItem(id: "2", amount: 800, type: .expense),
            makeItem(id: "3", amount: 200, type: .expense)
        ]
        let summary = vm.scenarioSummary(base: items)
        #expect(summary.totalIncome == 3500)
        #expect(summary.totalExpenses == 850)  // 800 + 50 (200 excluded)
        #expect(summary.balance == 2650)
    }
}
