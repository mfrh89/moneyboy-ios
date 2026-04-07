import Foundation

class ScenarioService {
    private let key = "moneyboy_scenario_whatif"

    func load() -> ScenarioData? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ScenarioData.self, from: data)
    }

    func save(_ scenario: ScenarioData?) {
        if let scenario, !scenario.isEmpty {
            let data = try? JSONEncoder().encode(scenario)
            UserDefaults.standard.set(data, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
