import Foundation
import FirebaseFirestore

extension FinanceItem {
    /// Initialize a FinanceItem from a Firestore document dictionary.
    /// Handles PWA's Unix-millisecond integers AND Firestore Timestamps.
    init?(documentID: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let amount = (data["amount"] as? Double) ?? (data["amount"] as? Int).map(Double.init),
            let typeRaw = data["type"] as? String,
            let type = TransactionType(rawValue: typeRaw),
            let category = data["category"] as? String
        else { return nil }

        self.id = documentID
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.isFlexible = data["isFlexible"] as? Bool ?? false
        self.isSplit = data["isSplit"] as? Bool ?? false
        self.isWohnkosten = data["isWohnkosten"] as? Bool ?? false
        self.excluded = data["excluded"] as? Bool ?? false
        self.isSubscription = data["isSubscription"] as? Bool ?? false
        self.subscriptionNextBilling = Self.decodeDate(data["subscriptionNextBilling"])
        self.subscriptionCancellationDeadline = Self.decodeDate(data["subscriptionCancellationDeadline"])
        if let cycleRaw = data["subscriptionCycle"] as? String {
            self.subscriptionCycle = SubscriptionCycle(rawValue: cycleRaw)
        } else {
            self.subscriptionCycle = nil
        }
        self.createdAt = Self.decodeDate(data["createdAt"]) ?? Date()
    }

    /// Decode a date from either a Firestore Timestamp or a Unix millisecond integer/double.
    private static func decodeDate(_ value: Any?) -> Date? {
        if let ts = value as? Timestamp {
            return ts.dateValue()
        }
        if let ms = value as? Double {
            return Date(timeIntervalSince1970: ms / 1000)
        }
        if let ms = value as? Int {
            return Date(timeIntervalSince1970: Double(ms) / 1000)
        }
        return nil
    }

    /// Convert to a Firestore-compatible dictionary.
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "title": title,
            "amount": amount,
            "type": type.rawValue,
            "category": category,
            "isFlexible": isFlexible,
            "isSplit": isSplit,
            "isWohnkosten": isWohnkosten,
            "excluded": excluded,
            "isSubscription": isSubscription,
            "createdAt": Timestamp(date: createdAt)
        ]
        if let nextBilling = subscriptionNextBilling {
            data["subscriptionNextBilling"] = Timestamp(date: nextBilling)
        }
        if let deadline = subscriptionCancellationDeadline {
            data["subscriptionCancellationDeadline"] = Timestamp(date: deadline)
        }
        if let cycle = subscriptionCycle {
            data["subscriptionCycle"] = cycle.rawValue
        }
        return data
    }
}
