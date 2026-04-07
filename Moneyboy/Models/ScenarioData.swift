import Foundation

struct ScenarioData: Codable {
    var overrides: [String: Double]
    var excluded: [String]
    var additions: [ScenarioAddition]

    init(overrides: [String: Double] = [:], excluded: [String] = [], additions: [ScenarioAddition] = []) {
        self.overrides = overrides
        self.excluded = excluded
        self.additions = additions
    }

    var isEmpty: Bool {
        overrides.isEmpty && excluded.isEmpty && additions.isEmpty
    }
}

struct ScenarioAddition: Codable, Identifiable {
    var id: String
    var title: String
    var amount: Double
    var typeRaw: String
    var category: String

    var type: FinanceItem.TransactionType {
        get { FinanceItem.TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    init(id: String = UUID().uuidString, title: String, amount: Double, type: FinanceItem.TransactionType, category: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.typeRaw = type.rawValue
        self.category = category
    }
}
