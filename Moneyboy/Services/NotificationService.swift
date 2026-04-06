import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseFirestore

class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    func registerFCMToken(uid: String) {
        guard let token = Messaging.messaging().fcmToken else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid)
            .collection("fcmTokens").document(token)
            .setData(["token": token, "createdAt": Timestamp()]) { _ in }
    }

    func scheduleSubscriptionAlerts(for items: [FinanceItem]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for item in items where item.isSubscription {
            scheduleDateAlert(for: item, date: item.subscriptionNextBilling, type: "Abrechnung", prefix: "💳")
            scheduleDateAlert(for: item, date: item.subscriptionCancellationDeadline, type: "Kündigungsfrist", prefix: "⚠️")
        }
    }

    private func scheduleDateAlert(for item: FinanceItem, date: Date?, type: String, prefix: String) {
        guard let date else { return }
        let alertDate = Calendar.current.date(byAdding: .day, value: -2, to: date) ?? date
        guard alertDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(prefix) \(item.title)"
        content.body = "\(type) in 2 Tagen: \(date.deShort) – \(item.amount.eurFormatted)"
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alertDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(item.id)-\(type)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
