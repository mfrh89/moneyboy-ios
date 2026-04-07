import SwiftUI

struct BalanceHeroCard: View {
    let summary: FinanceSummary

    var body: some View {
        VStack(spacing: 8) {
            Text("Verfügbar")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(summary.balance.eurFormatted)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: 20) {
                VStack(spacing: 2) {
                    Text("Einnahmen")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(summary.totalIncome.eurCompact)
                        .font(.footnote.bold())
                        .foregroundStyle(.green)
                }
                Divider().frame(height: 20)
                VStack(spacing: 2) {
                    Text("Ausgaben")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(summary.totalExpenses.eurCompact)
                        .font(.footnote.bold())
                        .foregroundStyle(.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }
}
