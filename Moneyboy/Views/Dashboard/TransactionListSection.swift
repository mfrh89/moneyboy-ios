import SwiftUI

struct TransactionListSection: View {
    let title: String
    let items: [FinanceItem]
    let onTap: (FinanceItem) -> Void
    let onToggleExcluded: (FinanceItem) -> Void

    private var subtotal: Double {
        items.filter { !$0.excluded }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                    Text(subtotal.eurFormatted)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(items) { item in
                        Button { onTap(item) } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.body)
                                        .foregroundStyle(item.excluded ? .secondary : .primary)
                                        .strikethrough(item.excluded)
                                    Text(item.category)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(item.amount.eurFormatted)
                                        .font(.body)
                                        .foregroundStyle(item.excluded ? .secondary : .primary)
                                        .strikethrough(item.excluded)
                                    if item.isSplit {
                                        Text("geteilt")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                }
                .padding(.horizontal)
            }
        }
    }
}
