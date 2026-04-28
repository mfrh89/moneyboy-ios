import SwiftUI

struct TrashView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var pendingPermanentDelete: FinanceItem?
    @State private var showingEmptyConfirm = false

    var body: some View {
        Group {
            if appViewModel.trashedItems.isEmpty {
                ContentUnavailableView(
                    "No Deleted Items",
                    systemImage: "trash",
                    description: Text("Items you delete will appear here for \(AppViewModel.trashRetentionDays) days.")
                )
            } else {
                List {
                    Section {
                        ForEach(appViewModel.trashedItems) { item in
                            row(item)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        appViewModel.restoreItem(item)
                                    } label: {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        pendingPermanentDelete = item
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    } footer: {
                        Text("Items are removed permanently after \(AppViewModel.trashRetentionDays) days.")
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Recently Deleted")
        .toolbar {
            if !appViewModel.trashedItems.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Empty", role: .destructive) {
                        showingEmptyConfirm = true
                    }
                }
            }
        }
        .confirmationDialog(
            "Empty Trash?",
            isPresented: $showingEmptyConfirm,
            titleVisibility: .visible
        ) {
            Button("Empty Trash", role: .destructive) {
                appViewModel.emptyTrash()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All \(appViewModel.trashedItems.count) items will be permanently deleted.")
        }
        .confirmationDialog(
            "Delete Permanently?",
            isPresented: Binding(
                get: { pendingPermanentDelete != nil },
                set: { if !$0 { pendingPermanentDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let item = pendingPermanentDelete {
                    appViewModel.permanentlyDelete(item)
                }
                pendingPermanentDelete = nil
            }
            Button("Cancel", role: .cancel) { pendingPermanentDelete = nil }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func row(_ item: FinanceItem) -> some View {
        let days = appViewModel.daysUntilPurge(for: item)
        let daysLabel: String = {
            if days <= 0 { return "Today" }
            if days == 1 { return "1 day left" }
            return "\(days) days left"
        }()

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                Text("\(item.sectionLabel) · \(daysLabel)")
                    .font(.caption)
                    .foregroundStyle(days <= 3 ? .orange : .secondary)
            }
            Spacer()
            Text(item.amount.eurFormatted)
                .foregroundStyle(.secondary)
        }
    }
}
