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

    func softDelete(_ item: FinanceItem) {
        item.deletedAt = .now
        save()
    }

    func restore(_ item: FinanceItem) {
        item.deletedAt = nil
        save()
    }

    func permanentlyDelete(_ item: FinanceItem) {
        modelContext.delete(item)
        save()
    }

    func emptyTrash() {
        for item in items where item.isDeleted {
            modelContext.delete(item)
        }
        save()
    }

    /// Hard-deletes items whose `deletedAt` is older than `cutoff`. Returns count purged.
    @discardableResult
    func purgeExpired(olderThan cutoff: Date) -> Int {
        var count = 0
        for item in items {
            if let deletedAt = item.deletedAt, deletedAt < cutoff {
                modelContext.delete(item)
                count += 1
            }
        }
        if count > 0 { save() }
        return count
    }

    func toggleExcluded(_ item: FinanceItem) {
        item.excluded.toggle()
        save()
    }

    /// Merges DTOs into the store: existing ids are overwritten, new ids are inserted.
    /// Local-only items are left untouched.
    @discardableResult
    func merge(_ dtos: [FinanceItemDTO]) -> ImportSummary {
        let byId = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        var inserted = 0
        var updated = 0
        for dto in dtos {
            if let existing = byId[dto.id] {
                dto.apply(to: existing)
                updated += 1
            } else {
                modelContext.insert(dto.makeItem())
                inserted += 1
            }
        }
        save()
        return ImportSummary(inserted: inserted, updated: updated)
    }

    private func save() {
        try? modelContext.save()
        fetchItems()
    }
}
