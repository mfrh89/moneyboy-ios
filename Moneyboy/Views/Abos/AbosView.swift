import SwiftUI

struct AbosView: View {
    @EnvironmentObject private var authService: AuthService
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
                // Total
                Section {
                    VStack(spacing: 4) {
                        Text("Monatliche Kosten")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text(monthlyTotal.eurFormatted)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Abonnements") {
                    ForEach(appViewModel.aboItems) { item in
                        Button { editingItem = item } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .foregroundStyle(item.excluded ? .secondary : .primary)
                                        .strikethrough(item.excluded)
                                    HStack(spacing: 6) {
                                        if let cycle = item.subscriptionCycle {
                                            Text(cycle == .monthly ? "monatlich" : "jährlich")
                                                .font(.caption)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                                                .foregroundStyle(.accentColor)
                                        }
                                        if let nb = item.subscriptionNextBilling {
                                            let days = nb.daysFromNow
                                            Text(days <= 2 ? "in \(days)d ⚠️" : nb.deShort)
                                                .font(.caption)
                                                .foregroundStyle(days <= 2 ? .orange : .secondary)
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
                                Task { try? await appViewModel.toggleExcluded(uid: authService.user!.uid, item: item) }
                            } label: {
                                Label(item.excluded ? "Einblenden" : "Ausblenden",
                                      systemImage: item.excluded ? "eye" : "eye.slash")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Abonnements")
            .sheet(item: $editingItem) { item in
                ItemFormSheet(existingItem: item)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
