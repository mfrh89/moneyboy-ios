import SwiftUI

struct SubscriptionAlertBanner: View {
    let items: [FinanceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Abo-Erinnerungen", systemImage: "bell.badge.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.orange)

            ForEach(items) { item in
                HStack {
                    Text(item.title)
                        .font(.callout)
                    Spacer()
                    if let date = item.subscriptionNextBilling {
                        Text(date.deShort)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                }
        }
    }
}
