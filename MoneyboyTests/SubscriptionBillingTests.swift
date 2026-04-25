import Testing
import Foundation
@testable import Moneyboy

@Suite("EffectiveNextBilling")
struct SubscriptionBillingTests {

    private func item(
        anchor: Date?,
        cycle: FinanceItem.SubscriptionCycle?
    ) -> FinanceItem {
        FinanceItem(
            title: "Sub",
            amount: 9.99,
            type: .expense,
            category: "Subscriptions",
            isSubscription: true,
            subscriptionNextBilling: anchor,
            subscriptionCycle: cycle
        )
    }

    @Test func nilAnchorReturnsNil() {
        #expect(item(anchor: nil, cycle: .monthly).effectiveNextBilling == nil)
    }

    @Test func futureAnchorReturnedAsIs() {
        let cal = Calendar.current
        let future = cal.date(byAdding: .day, value: 5, to: cal.startOfDay(for: .now))!
        let result = item(anchor: future, cycle: .monthly).effectiveNextBilling
        #expect(result == future)
    }

    @Test func pastMonthlyRollsForward() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let past = cal.date(byAdding: .month, value: -3, to: today)!
        guard let next = item(anchor: past, cycle: .monthly).effectiveNextBilling else {
            Issue.record("expected non-nil")
            return
        }
        #expect(next >= today)
        #expect(cal.component(.day, from: next) == cal.component(.day, from: past))
    }

    @Test func pastYearlyRollsForward() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let past = cal.date(byAdding: .year, value: -2, to: today)!
        guard let next = item(anchor: past, cycle: .yearly).effectiveNextBilling else {
            Issue.record("expected non-nil")
            return
        }
        #expect(next >= today)
        let pastComps = cal.dateComponents([.month, .day], from: past)
        let nextComps = cal.dateComponents([.month, .day], from: next)
        #expect(pastComps.month == nextComps.month)
        #expect(pastComps.day == nextComps.day)
    }

    @Test func pastWithoutCycleReturnsAnchor() {
        let cal = Calendar.current
        let past = cal.date(byAdding: .day, value: -10, to: .now)!
        #expect(item(anchor: past, cycle: nil).effectiveNextBilling == past)
    }

    @Test func todayAnchorReturnedAsIs() {
        let today = Calendar.current.startOfDay(for: .now)
        #expect(item(anchor: today, cycle: .monthly).effectiveNextBilling == today)
    }
}
