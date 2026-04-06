import Foundation
import FirebaseFirestore

class ScenarioService {
    private let db = Firestore.firestore()

    func load(uid: String) async throws -> ScenarioData? {
        let snap = try await db
            .collection("users").document(uid)
            .collection("scenarios").document("whatif")
            .getDocument()

        guard snap.exists, let data = snap.data() else { return nil }

        let overrides = data["overrides"] as? [String: Double] ?? [:]
        let excluded = data["excluded"] as? [String] ?? []

        var additions: [FinanceItem] = []
        if let additionsData = data["additions"] as? [[String: Any]] {
            additions = additionsData.compactMap {
                FinanceItem(documentID: $0["id"] as? String ?? UUID().uuidString, data: $0)
            }
        }

        return ScenarioData(overrides: overrides, excluded: excluded, additions: additions)
    }

    func save(uid: String, scenario: ScenarioData?) async throws {
        let ref = db
            .collection("users").document(uid)
            .collection("scenarios").document("whatif")

        guard let scenario else {
            try await ref.delete()
            return
        }

        let additionsData = scenario.additions.map { $0.toFirestoreData() }

        try await ref.setData([
            "overrides": scenario.overrides,
            "excluded": scenario.excluded,
            "additions": additionsData
        ])
    }
}
