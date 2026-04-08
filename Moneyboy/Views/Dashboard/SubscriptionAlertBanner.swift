import SwiftUI

struct SubscriptionAlertBanner: View {
    let items: [FinanceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Abo-Erinnerungen", systemImage: "bell.badge.fill")
                .font(.subheadline.bold())
                .labelStyle(.titleAndIcon)


            ForEach(items) { item in
                HStack {
                    Text(item.title)
                        .font(.caption)
                    Spacer()
                    if let date = item.subscriptionNextBilling {
                        Text(date.deShort)
                            .font(.caption2)
                            .opacity(0.7)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.white)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                }
        }
    }
}
