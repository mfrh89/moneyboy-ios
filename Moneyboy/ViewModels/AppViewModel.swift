import Foundation
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var items: [FinanceItem] = []

    private let firestoreService = FirestoreService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        firestoreService.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }

    func subscribe(uid: String) {
        firestoreService.subscribe(uid: uid)
    }

    func unsubscribe() {
        firestoreService.unsubscribe()
    }

    // MARK: - Computed

    var summary: FinanceSummary { .compute(from: items) }

    var incomeItems: [FinanceItem] {
        items.filter { $0.type == .income }
    }

    var fixedExpenseItems: [FinanceItem] {
        items.filter { $0.type == .expense && !$0.isFlexible && !$0.isWohnkosten }
    }

    var flexibleExpenseItems: [FinanceItem] {
        items.filter { $0.type == .expense && $0.isFlexible && !$0.isWohnkosten }
    }

    var wohnkostenItems: [FinanceItem] {
        items.filter { $0.isWohnkosten }
    }

    var aboItems: [FinanceItem] {
        items.filter { $0.isSubscription }
    }

    var upcomingSubscriptions: [FinanceItem] {
        items.filter { item in
            guard item.isSubscription else { return false }
            let dates = [item.subscriptionNextBilling, item.subscriptionCancellationDeadline].compactMap { $0 }
            return dates.contains { $0.daysFromNow >= 0 && $0.daysFromNow <= 2 }
        }
    }

    var availableCategories: [String] {
        let defaults = [
            "Gehalt", "Nebeneinkommen", "Wohnen", "Lebensmittel", "Lebenshaltung",
            "Transport", "Versicherungen", "Abonnements", "Gesundheit",
            "Freizeit", "Kleidung", "Bildung", "Sonstiges"
        ]
        let used = Set(items.map { $0.category })
        return Array(Set(defaults).union(used)).sorted()
    }

    // MARK: - Mutations

    func addItem(uid: String, item: FinanceItem) async throws {
        try await firestoreService.addItem(uid: uid, item: item)
    }

    func updateItem(uid: String, item: FinanceItem) async throws {
        try await firestoreService.updateItem(uid: uid, item: item)
    }

    func deleteItem(uid: String, itemId: String) async throws {
        try await firestoreService.deleteItem(uid: uid, itemId: itemId)
    }

    func toggleExcluded(uid: String, item: FinanceItem) async throws {
        var updated = item
        updated.excluded.toggle()
        try await updateItem(uid: uid, item: updated)
    }
}
