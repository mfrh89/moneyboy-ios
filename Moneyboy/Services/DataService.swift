import Foundation
import SwiftData

@MainActor
class DataService: ObservableObject {
    private let modelContext: ModelContext

    @Published var items: [FinanceItem] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchItems()
    }

    func fetchItems() {
        let descriptor = FetchDescriptor<FinanceItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        items = (try? modelContext.fetch(descriptor)) ?? []
    }

    func addItem(_ item: FinanceItem) {
        modelContext.insert(item)
        save()
    }

    func updateItem(_ item: FinanceItem) {
        save()
    }

    func deleteItem(_ item: FinanceItem) {
        modelContext.delete(item)
        save()
    }

    func toggleExcluded(_ item: FinanceItem) {
        item.excluded.toggle()
        save()
    }

    private func save() {
        try? modelContext.save()
        fetchItems()
    }
}
