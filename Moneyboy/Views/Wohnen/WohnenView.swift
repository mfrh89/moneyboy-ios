import SwiftUI

struct WohnenView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var editingItem: FinanceItem?
    @State private var showingAddSheet = false

    private var total: Double {
        appViewModel.wohnkostenItems
            .filter { !$0.excluded }
            .reduce(0) { $0 + $1.amount }
    }

    private var hasSplitItems: Bool {
        appViewModel.wohnkostenItems.contains { !$0.excluded && $0.isSplit }
    }

    private var combinedTotal: Double {
        appViewModel.wohnkostenItems
            .filter { !$0.excluded }
            .reduce(0) { $0 + ($1.isSplit ? $1.amount * 2 : $1.amount) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 6) {
                        Text("Monatliche Wohnkosten")
                            .font(.caption2.weight(.medium))
                            .tracking(0.5)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        if appViewModel.wohnkostenItems.isEmpty {
                            Text("—")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("Füge unten Kosten hinzu")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(total.eurFormatted)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            if hasSplitItems {
                                Text("Gesamt: \(combinedTotal.eurFormatted)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Wohnkosten") {
                    if appViewModel.wohnkostenItems.isEmpty {
                        Text("Noch keine Wohnkosten erfasst.")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    } else {
                        ForEach(appViewModel.wohnkostenItems) { item in
                            Button { editingItem = item } label: {
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
                                            .strikethrough(item.excluded)
                                        if item.isSplit {
                                            Text("½ von \((item.amount * 2).eurFormatted)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    appViewModel.toggleExcluded(item)
                                } label: {
                                    Label(item.excluded ? "Einblenden" : "Ausblenden",
                                          systemImage: item.excluded ? "eye" : "eye.slash")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .tint(.primary)
            .navigationTitle("Wohnen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ItemFormSheet(presetWohnkosten: true)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $editingItem) { item in
                ItemFormSheet(existingItem: item)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
