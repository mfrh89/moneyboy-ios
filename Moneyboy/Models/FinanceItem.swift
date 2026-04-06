import Foundation

struct FinanceItem: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var amount: Double
    var type: TransactionType
    var category: String
    var isFlexible: Bool
    var isSplit: Bool
    var isWohnkosten: Bool
    var excluded: Bool
    var isSubscription: Bool
    var subscriptionNextBilling: Date?
    var subscriptionCancellationDeadline: Date?
    var subscriptionCycle: SubscriptionCycle?
    var createdAt: Date

    enum TransactionType: String, Codable {
        case income
        case expense
    }

    enum SubscriptionCycle: String, Codable {
        case monthly
        case yearly
    }

    enum CodingKeys: String, CodingKey {
        case id, title, amount, type, category
        case isFlexible, isSplit, isWohnkosten, excluded
        case isSubscription, subscriptionNextBilling, subscriptionCancellationDeadline, subscriptionCycle
        case createdAt
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        amount: Double,
        type: TransactionType,
        category: String,
        isFlexible: Bool = false,
        isSplit: Bool = false,
        isWohnkosten: Bool = false,
        excluded: Bool = false,
        isSubscription: Bool = false,
        subscriptionNextBilling: Date? = nil,
        subscriptionCancellationDeadline: Date? = nil,
        subscriptionCycle: SubscriptionCycle? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.isFlexible = isFlexible
        self.isSplit = isSplit
        self.isWohnkosten = isWohnkosten
        self.excluded = excluded
        self.isSubscription = isSubscription
        self.subscriptionNextBilling = subscriptionNextBilling
        self.subscriptionCancellationDeadline = subscriptionCancellationDeadline
        self.subscriptionCycle = subscriptionCycle
        self.createdAt = createdAt
    }
}
