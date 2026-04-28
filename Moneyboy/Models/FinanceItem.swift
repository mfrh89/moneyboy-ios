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
    var deletedAt: Date?

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

    /// Next billing occurrence ≥ today, computed from the stored anchor and cycle.
    /// The anchor stays stable; this rolls forward by month/year as time passes.
    var effectiveNextBilling: Date? {
        guard let anchor = subscriptionNextBilling else { return nil }
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        if anchor >= today { return anchor }
        let component: Calendar.Component
        switch subscriptionCycle {
        case .monthly: component = .month
        case .yearly:  component = .year
        case .none:    return anchor
        }
        let elapsed = cal.dateComponents([component], from: anchor, to: today).value(for: component) ?? 0
        var next = cal.date(byAdding: component, value: max(0, elapsed), to: anchor) ?? anchor
        while next < today {
            guard let advanced = cal.date(byAdding: component, value: 1, to: next) else { break }
            next = advanced
        }
        return next
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
        createdAt: Date = Date(),
        deletedAt: Date? = nil
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
        self.deletedAt = deletedAt
    }

    var isDeleted: Bool { deletedAt != nil }

    /// Section label used in the trash view to indicate where this item came from.
    /// Order matters: subscription wins over housing wins over income/expense flags.
    var sectionLabel: String {
        if isSubscription { return "Subscription" }
        if isWohnkosten { return "Housing" }
        if type == .income { return "Income" }
        return isFlexible ? "Variable Expense" : "Fixed Expense"
    }
}
