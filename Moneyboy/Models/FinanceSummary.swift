import Foundation

struct FinanceSummary {
    let totalIncome: Double
    let totalExpenses: Double
    let balance: Double

    static func compute(from items: [FinanceItem]) -> FinanceSummary {
        let income = items
            .filter { $0.type == .income && !$0.excluded && !$0.isDeleted }
            .reduce(0) { $0 + $1.amount }

        let expenses = items
            .filter { $0.type == .expense && !$0.excluded && !$0.isDeleted }
            .reduce(0) { $0 + $1.amount }

        return FinanceSummary(
            totalIncome: income,
            totalExpenses: expenses,
            balance: income - expenses
        )
    }
}
