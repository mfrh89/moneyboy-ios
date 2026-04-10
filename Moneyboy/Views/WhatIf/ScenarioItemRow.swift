import SwiftUI

struct ScenarioItemRow: View {
    let item: FinanceItem
    let isExcluded: Bool
    let override: Double?
    let onExclude: () -> Void
    let onOverride: (Double) -> Void
    let onClearOverride: () -> Void

    @State private var editingAmount = false
    @State private var amountText = ""
    @FocusState private var focused: Bool

    private var displayAmount: Double {
        override ?? item.amount
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .foregroundStyle(isExcluded ? .secondary : .primary)
                    .strikethrough(isExcluded)
                Text(item.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if editingAmount {
                HStack(spacing: 6) {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                        .focused($focused)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            amountText = String(format: "%.2f", displayAmount)
                            focused = true
                        }

                    Button {
                        if let val = Double(amountText.replacingOccurrences(of: ",", with: ".")) {
                            onOverride(val)
                        }
                        editingAmount = false
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.green.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    Button {
                        editingAmount = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.secondary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 6) {
                    Text(displayAmount.eurFormatted)
                        .foregroundStyle(isExcluded ? .secondary : .primary)
                        .strikethrough(isExcluded)

                    Button {
                        editingAmount = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .frame(width: 28, height: 28)
                            .background(Color.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onExclude()
                    } label: {
                        Image(systemName: isExcluded ? "eye" : "eye.slash")
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .frame(width: 28, height: 28)
                            .background(Color.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .swipeActions(edge: .leading) {
            if override != nil {
                Button("Reset", role: .destructive) {
                    onClearOverride()
                }
                .tint(.orange)
            }
        }
    }
}
