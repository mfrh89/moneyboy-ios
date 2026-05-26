import Foundation

struct FinanceItemDTO: Codable {
    var id: String
    var title: String
    var amount: Double
    var typeRaw: String
    var category: String
    var isFlexible: Bool
    var isSplit: Bool
    var isWohnkosten: Bool
    var excluded: Bool
    var isSubscription: Bool
    var subscriptionNextBilling: Date?
    var subscriptionCancellationDeadline: Date?
    var subscriptionCycleRaw: String?
    var createdAt: Date
    var deletedAt: Date?

    init(from item: FinanceItem) {
        self.id = item.id
        self.title = item.title
        self.amount = item.amount
        self.typeRaw = item.typeRaw
        self.category = item.category
        self.isFlexible = item.isFlexible
        self.isSplit = item.isSplit
        self.isWohnkosten = item.isWohnkosten
        self.excluded = item.excluded
        self.isSubscription = item.isSubscription
        self.subscriptionNextBilling = item.subscriptionNextBilling
        self.subscriptionCancellationDeadline = item.subscriptionCancellationDeadline
        self.subscriptionCycleRaw = item.subscriptionCycleRaw
        self.createdAt = item.createdAt
        self.deletedAt = item.deletedAt
    }

    func makeItem() -> FinanceItem {
        FinanceItem(
            id: id,
            title: title,
            amount: amount,
            type: FinanceItem.TransactionType(rawValue: typeRaw) ?? .expense,
            category: category,
            isFlexible: isFlexible,
            isSplit: isSplit,
            isWohnkosten: isWohnkosten,
            excluded: excluded,
            isSubscription: isSubscription,
            subscriptionNextBilling: subscriptionNextBilling,
            subscriptionCancellationDeadline: subscriptionCancellationDeadline,
            subscriptionCycle: subscriptionCycleRaw.flatMap { FinanceItem.SubscriptionCycle(rawValue: $0) },
            createdAt: createdAt,
            deletedAt: deletedAt
        )
    }

    func apply(to item: FinanceItem) {
        item.title = title
        item.amount = amount
        item.typeRaw = typeRaw
        item.category = category
        item.isFlexible = isFlexible
        item.isSplit = isSplit
        item.isWohnkosten = isWohnkosten
        item.excluded = excluded
        item.isSubscription = isSubscription
        item.subscriptionNextBilling = subscriptionNextBilling
        item.subscriptionCancellationDeadline = subscriptionCancellationDeadline
        item.subscriptionCycleRaw = subscriptionCycleRaw
        item.createdAt = createdAt
        item.deletedAt = deletedAt
    }
}

struct BackupFile: Codable {
    static let currentVersion = 1

    var version: Int
    var exportedAt: Date
    var items: [FinanceItemDTO]

    init(items: [FinanceItem], exportedAt: Date = .now) {
        self.version = Self.currentVersion
        self.exportedAt = exportedAt
        self.items = items.map(FinanceItemDTO.init(from:))
    }
}
