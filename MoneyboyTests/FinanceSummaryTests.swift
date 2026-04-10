import Testing
import SwiftData
@testable import Moneyboy

@Suite("FinanceSummary")
struct FinanceSummaryTests {

    private func makeItem(
        title: String = "Test",
        amount: Double,
        type: FinanceItem.TransactionType,
        excluded: Bool = false
    ) -> FinanceItem {
        FinanceItem(
            title: title,
            amount: amount,
            type: type,
            category: "Other",
            excluded: excluded
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
}
