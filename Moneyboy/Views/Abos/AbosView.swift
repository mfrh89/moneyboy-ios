import SwiftUI

struct AbosView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var editingItem: FinanceItem?

    private var monthlyTotal: Double {
        appViewModel.aboItems.filter { !$0.excluded }.reduce(0) { sum, item in
            switch item.subscriptionCycle {
            case .yearly: return sum + item.amount / 12
            default: return sum + item.amount
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 6) {
                        Text("Monthly Costs")
                            .font(.caption2.weight(.medium))
                            .tracking(0.5)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(monthlyTotal.eurFormatted)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Subscriptions") {
                    ForEach(appViewModel.aboItems) { item in
                        Button { editingItem = item } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .foregroundStyle(item.excluded ? .secondary : .primary)
                                        .strikethrough(item.excluded)
                                    HStack(spacing: 6) {
                                        if let cycle = item.subscriptionCycle {
                                            Text(cycle == .monthly ? "monthly" : "yearly")
                                                .font(.caption)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.secondary.opacity(0.2), in: Capsule())
                                                .foregroundStyle(.primary)
                                        }
                                        if let nb = item.effectiveNextBilling {
                                            let days = nb.daysFromNow
                                            let suffix = days <= 2 ? " ⚠️" : ""
                                            Text("\(nb.deShort) · in \(days)d\(suffix)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                Text(item.amount.eurFormatted)
                                    .strikethrough(item.excluded)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                appViewModel.toggleExcluded(item)
                            } label: {
                                Label(item.excluded ? "Show" : "Hide",
                                      systemImage: item.excluded ? "eye" : "eye.slash")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .tint(.primary)
            .navigationTitle("Subscriptions")
            .sheet(item: $editingItem) { item in
                ItemFormSheet(existingItem: item)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
