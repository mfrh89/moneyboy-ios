import SwiftUI

struct WohnenView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var editingItem: FinanceItem?

    private var total: Double {
        appViewModel.wohnkostenItems
            .filter { !$0.excluded }
            .reduce(0) { $0 + $1.amount }
    }

    private var splitTotal: Double {
        appViewModel.wohnkostenItems
            .filter { !$0.excluded && $0.isSplit }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            List {
                // Total card
                Section {
                    VStack(spacing: 8) {
                        Text("Wohnkosten gesamt")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text(total.eurFormatted)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                        if splitTotal > 0 {
                            Text("davon geteilt: \(splitTotal.eurFormatted)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Einträge") {
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
            .navigationTitle("Wohnen")
            .sheet(item: $editingItem) { item in
                ItemFormSheet(existingItem: item)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
