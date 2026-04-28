import Foundation
import Testing
import SwiftData
@testable import Moneyboy

@Suite("FinanceSummary")
struct FinanceSummaryTests {

    private func makeItem(
        title: String = "Test",
        amount: Double,
        type: FinanceItem.TransactionType,
        excluded: Bool = false,
        deletedAt: Date? = nil
    ) -> FinanceItem {
        FinanceItem(
            title: title,
            amount: amount,
            type: type,
            category: "Other",
            excluded: excluded,
            deletedAt: deletedAt
        )
    }

    @Test func emptyItems() {
        let summary = FinanceSummary.compute(from: [])
        #expect(summary.totalIncome == 0)
        #expect(summary.totalExpenses == 0)
        #expect(summary.balance == 0)
    }

    @Test func incomeOnly() {
        let items = [
            makeItem(amount: 3000, type: .income),
            makeItem(amount: 500, type: .income)
        ]
        let summary = FinanceSummary.compute(from: items)
        #expect(summary.totalIncome == 3500)
        #expect(summary.totalExpenses == 0)
        #expect(summary.balance == 3500)
    }

    @Test func expensesOnly() {
        let items = [
            makeItem(amount: 800, type: .expense),
            makeItem(amount: 200, type: .expense)
        ]
        let summary = FinanceSummary.compute(from: items)
        #expect(summary.totalIncome == 0)
        #expect(summary.totalExpenses == 1000)
        #expect(summary.balance == -1000)
    }

    @Test func mixedIncomeAndExpenses() {
        let items = [
            makeItem(amount: 3000, type: .income),
            makeItem(amount: 800, type: .expense),
            makeItem(amount: 200, type: .expense)
        ]
        let summary = FinanceSummary.compute(from: items)
        #expect(summary.totalIncome == 3000)
        #expect(summary.totalExpenses == 1000)
        #expect(summary.balance == 2000)
    }

    @Test func excludedItemsAreIgnored() {
        let items = [
            makeItem(amount: 3000, type: .income),
            makeItem(amount: 1000, type: .income, excluded: true),
            makeItem(amount: 500, type: .expense),
            makeItem(amount: 300, type: .expense, excluded: true)
        ]
        let summary = FinanceSummary.compute(from: items)
        #expect(summary.totalIncome == 3000)
        #expect(summary.totalExpenses == 500)
        #expect(summary.balance == 2500)
    }

    @Test func deletedItemsAreIgnored() {
        let items = [
            makeItem(amount: 3000, type: .income),
            makeItem(amount: 1000, type: .income, deletedAt: .now),
            makeItem(amount: 500, type: .expense),
            makeItem(amount: 300, type: .expense, deletedAt: .now)
        ]
        let summary = FinanceSummary.compute(from: items)
        #expect(summary.totalIncome == 3000)
        #expect(summary.totalExpenses == 500)
        #expect(summary.balance == 2500)
    }

    @Test func sectionLabelMapping() {
        #expect(makeItem(amount: 1000, type: .income).sectionLabel == "Income")

        let fixed = FinanceItem(title: "x", amount: 100, type: .expense, category: "Other")
        #expect(fixed.sectionLabel == "Fixed Expense")

        let flex = FinanceItem(title: "x", amount: 100, type: .expense, category: "Other", isFlexible: true)
        #expect(flex.sectionLabel == "Variable Expense")

        let housing = FinanceItem(title: "x", amount: 100, type: .expense, category: "Housing", isWohnkosten: true)
        #expect(housing.sectionLabel == "Housing")

        let sub = FinanceItem(title: "x", amount: 100, type: .expense, category: "Subs", isWohnkosten: true, isSubscription: true)
        #expect(sub.sectionLabel == "Subscription")
    }
}
