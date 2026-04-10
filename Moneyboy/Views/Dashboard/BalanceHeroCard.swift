import SwiftUI

struct BalanceHeroCard: View {
    let summary: FinanceSummary

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Available")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(summary.balance.eurFormatted)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(summary.totalIncome.eurCompact)
                        .font(.subheadline.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Text("Expenses")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(summary.totalExpenses.eurCompact)
                        .font(.subheadline.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
