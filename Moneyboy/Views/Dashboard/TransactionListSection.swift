import SwiftUI

struct TransactionListSection: View {
    let title: String
    let items: [FinanceItem]
    let onTap: (FinanceItem) -> Void
    let onToggleExcluded: (FinanceItem) -> Void

    var body: some View {
        Section(title) {
            ForEach(items) { item in
                Button { onTap(item) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .foregroundStyle(item.excluded ? .secondary : .primary)
                                .strikethrough(item.excluded)
                            Text(item.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.amount.eurFormatted)
                                .foregroundStyle(item.type == .income ? .green : .primary)
                                .strikethrough(item.excluded)
                            if item.isSplit {
                                Text("geteilt")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        onToggleExcluded(item)
                    } label: {
                        Label(
                            item.excluded ? "Einblenden" : "Ausblenden",
                            systemImage: item.excluded ? "eye" : "eye.slash"
                        )
                    }
                    .tint(.orange)
                }
            }
        }
    }
}
