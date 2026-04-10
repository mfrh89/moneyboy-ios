import Testing
import Foundation
@testable import Moneyboy

@Suite("ScenarioData")
struct ScenarioDataTests {

    @Test func emptyScenarioIsEmpty() {
        let data = ScenarioData()
        #expect(data.isEmpty)
    }

    @Test func scenarioWithOverridesIsNotEmpty() {
        let data = ScenarioData(overrides: ["id": 500])
        #expect(!data.isEmpty)
    }

    @Test func scenarioWithExcludedIsNotEmpty() {
        let data = ScenarioData(excluded: ["id"])
        #expect(!data.isEmpty)
    }

    @Test func scenarioWithAdditionsIsNotEmpty() {
        let addition = ScenarioAddition(title: "Test", amount: 100, type: .expense, category: "Other")
        let data = ScenarioData(additions: [addition])
        #expect(!data.isEmpty)
    }

    @Test func scenarioAdditionTypeMapping() {
        var addition = ScenarioAddition(title: "Job", amount: 1000, type: .income, category: "Salary")
        #expect(addition.type == .income)
        #expect(addition.typeRaw == "income")

        addition.type = .expense
        #expect(addition.typeRaw == "expense")
    }

    @Test func scenarioDataEncodesDecodes() throws {
        let addition = ScenarioAddition(title: "Gym", amount: 50, type: .expense, category: "Health")
        let original = ScenarioData(
            overrides: ["item-1": 999.5],
            excluded: ["item-2"],
            additions: [addition]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ScenarioData.self, from: data)

        #expect(decoded.overrides == original.overrides)
        #expect(decoded.excluded == original.excluded)
        #expect(decoded.additions.count == 1)
        #expect(decoded.additions.first?.title == "Gym")
        #expect(decoded.additions.first?.amount == 50)
        #expect(decoded.additions.first?.type == .expense)
    }
}
