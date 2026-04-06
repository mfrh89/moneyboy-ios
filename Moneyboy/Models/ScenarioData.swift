import Foundation

struct ScenarioData: Codable {
    var overrides: [String: Double]
    var excluded: [String]
    var additions: [FinanceItem]

    init(overrides: [String: Double] = [:], excluded: [String] = [], additions: [FinanceItem] = []) {
        self.overrides = overrides
        self.excluded = excluded
        self.additions = additions
    }

    var isEmpty: Bool {
        overrides.isEmpty && excluded.isEmpty && additions.isEmpty
    }
}
