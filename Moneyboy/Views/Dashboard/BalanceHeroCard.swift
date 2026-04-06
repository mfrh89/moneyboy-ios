import SwiftUI

struct BalanceHeroCard: View {
    let summary: FinanceSummary

    var body: some View {
        VStack(spacing: 12) {
            Text("Verfügbar")
                .font(.callout)
                .foregroundStyle(.secondary)

            Text(summary.balance.eurFormatted)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(summary.balance >= 0 ? Color.primary : Color.red)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text("Einnahmen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(summary.totalIncome.eurCompact)
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
                Divider().frame(height: 28)
                VStack(spacing: 2) {
                    Text("Ausgaben")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(summary.totalExpenses.eurCompact)
                        .font(.subheadline.bold())
                        .foregroundStyle(.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
        }
    }
}
