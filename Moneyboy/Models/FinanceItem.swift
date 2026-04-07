import Foundation
import SwiftData

@Model
final class FinanceItem: Identifiable {
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

    enum TransactionType: String, Codable {
        case income
        case expense
    }

    enum SubscriptionCycle: String, Codable {
        case monthly
        case yearly
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var subscriptionCycle: SubscriptionCycle? {
        get { subscriptionCycleRaw.flatMap { SubscriptionCycle(rawValue: $0) } }
        set { subscriptionCycleRaw = newValue?.rawValue }
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
        self.typeRaw = type.rawValue
        self.category = category
        self.isFlexible = isFlexible
        self.isSplit = isSplit
        self.isWohnkosten = isWohnkosten
        self.excluded = excluded
        self.isSubscription = isSubscription
        self.subscriptionNextBilling = subscriptionNextBilling
        self.subscriptionCancellationDeadline = subscriptionCancellationDeadline
        self.subscriptionCycleRaw = subscriptionCycle?.rawValue
        self.createdAt = createdAt
    }
}
