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
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "sum")
                            .font(.system(size: 9))
                        Text(subtotal.eurFormatted)
                            .font(.body)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        if index > 0 {
                            Divider()
                                .padding(.horizontal)
                        }
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
                                        Text("split")
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
