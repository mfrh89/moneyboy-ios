import Foundation
import SwiftData
import Combine

@MainActor
class AppViewModel: ObservableObject {
    private var dataService: DataService?

    @Published var items: [FinanceItem] = []
    @Published var hiddenCategories: Set<String> = []
    @Published var customCategories: [String] = []
    private var cancellables = Set<AnyCancellable>()

    private let hiddenKey = "moneyboy_hidden_categories"
    private let customKey = "moneyboy_custom_categories"

    func setup(modelContext: ModelContext) {
        let service = DataService(modelContext: modelContext)
        self.dataService = service
        service.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
        hiddenCategories = Set(UserDefaults.standard.stringArray(forKey: hiddenKey) ?? [])
        customCategories = UserDefaults.standard.stringArray(forKey: customKey) ?? []
    }

    // MARK: - Computed

    var summary: FinanceSummary { .compute(from: items) }

    var incomeItems: [FinanceItem] {
        items.filter { $0.type == .income }.sorted { $0.amount > $1.amount }
    }

    var fixedExpenseItems: [FinanceItem] {
        items.filter { $0.type == .expense && !$0.isFlexible && !$0.isWohnkosten }.sorted { $0.amount > $1.amount }
    }

    var flexibleExpenseItems: [FinanceItem] {
        items.filter { $0.type == .expense && $0.isFlexible && !$0.isWohnkosten }.sorted { $0.amount > $1.amount }
    }

    var wohnkostenItems: [FinanceItem] {
        items.filter { $0.isWohnkosten }.sorted { $0.amount > $1.amount }
    }

    var aboItems: [FinanceItem] {
        items.filter { $0.isSubscription }.sorted { $0.amount > $1.amount }
    }

    var upcomingSubscriptions: [FinanceItem] {
        items.filter { item in
            guard item.isSubscription else { return false }
            let dates = [item.effectiveNextBilling, item.subscriptionCancellationDeadline].compactMap { $0 }
            return dates.contains { $0.daysFromNow >= 0 && $0.daysFromNow <= 2 }
        }
    }

    private let defaultCategories = [
        "Salary", "Side Income", "Housing", "Groceries", "Living Expenses",
        "Transport", "Insurance", "Subscriptions", "Health",
        "Leisure", "Clothing", "Education", "Other"
    ]

    var availableCategories: [String] {
        let used = Set(items.map { $0.category })
        let all = Set(defaultCategories).union(used).union(customCategories)
        return all.subtracting(hiddenCategories).sorted()
    }

    func addCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        customCategories.append(trimmed)
        hiddenCategories.remove(trimmed)
        UserDefaults.standard.set(customCategories, forKey: customKey)
        UserDefaults.standard.set(Array(hiddenCategories), forKey: hiddenKey)
    }

    func deleteCategory(_ name: String) {
        hiddenCategories.insert(name)
        customCategories.removeAll { $0 == name }
        UserDefaults.standard.set(Array(hiddenCategories), forKey: hiddenKey)
        UserDefaults.standard.set(customCategories, forKey: customKey)
    }

    func renameCategory(from old: String, to new: String) {
        let trimmed = new.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        // Update all items using this category
        for item in items where item.category == old {
            item.category = trimmed
            dataService?.updateItem(item)
        }
        // Update custom list
        if let idx = customCategories.firstIndex(of: old) {
            customCategories[idx] = trimmed
        } else {
            customCategories.append(trimmed)
        }
        hiddenCategories.remove(trimmed)
        hiddenCategories.insert(old)
        UserDefaults.standard.set(customCategories, forKey: customKey)
        UserDefaults.standard.set(Array(hiddenCategories), forKey: hiddenKey)
    }

    // MARK: - Mutations

    func addItem(_ item: FinanceItem) {
        dataService?.addItem(item)
    }

    func updateItem(_ item: FinanceItem) {
        dataService?.updateItem(item)
    }

    func deleteItem(_ item: FinanceItem) {
        dataService?.deleteItem(item)
    }

    func toggleExcluded(_ item: FinanceItem) {
        dataService?.toggleExcluded(item)
    }
}
