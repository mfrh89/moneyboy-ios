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
                HStack(spacing: 8) {
                    TextField("Betrag", text: $amountText)
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
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .frame(width: 44, height: 44)

                    Button {
                        editingAmount = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 44, height: 44)
                }
            } else {
                HStack(spacing: 12) {
                    Text(displayAmount.eurFormatted)
                        .foregroundStyle(override != nil ? .orange : (isExcluded ? .secondary : .primary))
                        .strikethrough(isExcluded)

                    Button {
                        editingAmount = true
                    } label: {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 44, height: 44)

                    Button {
                        onExclude()
                    } label: {
                        Image(systemName: isExcluded ? "eye" : "eye.slash")
                            .foregroundStyle(isExcluded ? .green : .secondary)
                    }
                    .frame(width: 44, height: 44)
                }
            }
        }
        .swipeActions(edge: .leading) {
            if override != nil {
                Button("Zurücksetzen", role: .destructive) {
                    onClearOverride()
                }
                .tint(.orange)
            }
        }
    }
}
