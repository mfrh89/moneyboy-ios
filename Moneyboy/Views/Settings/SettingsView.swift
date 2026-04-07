import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var renamingCategory: String?
    @State private var renameText = ""
    @State private var notificationsEnabled = false
    @State private var deletingCategory: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Was wäre wenn") {
                    NavigationLink {
                        WhatIfView()
                    } label: {
                        Label("Szenario-Planer", systemImage: "lightbulb")
                    }
                }

                Section {
                    FlowLayout(spacing: 10) {
                        ForEach(appViewModel.availableCategories, id: \.self) { cat in
                            HStack(spacing: 0) {
                                Button {
                                    renamingCategory = cat
                                    renameText = cat
                                } label: {
                                    Text(cat)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .frame(height: 20)

                                Button {
                                    deletingCategory = cat
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(.plain)
                            }
                            .font(.body)
                            .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    HStack {
                        Text("Kategorien")
                        Spacer()
                        Button { showingAddCategory = true } label: {
                            Image(systemName: "plus")
                                .font(.body)
                        }
                    }
                }

                Section("Benachrichtigungen") {
                    Toggle("Abo-Erinnerungen", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                Task {
                                    let granted = await NotificationService.shared.requestPermission()
                                    if granted {
                                        NotificationService.shared.scheduleSubscriptionAlerts(for: appViewModel.aboItems)
                                    } else {
                                        notificationsEnabled = false
                                    }
                                }
                            }
                        }
                }

                Section("Daten") {
                    LabeledContent("Einträge", value: "\(appViewModel.items.count)")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Einstellungen")
            .alert("Neue Kategorie", isPresented: $showingAddCategory) {
                TextField("Name", text: $newCategoryName)
                Button("Hinzufügen") {
                    appViewModel.addCategory(newCategoryName)
                    newCategoryName = ""
                }
                Button("Abbrechen", role: .cancel) { newCategoryName = "" }
            }
            .alert("Umbenennen", isPresented: Binding(
                get: { renamingCategory != nil },
                set: { if !$0 { renamingCategory = nil } }
            )) {
                TextField("Neuer Name", text: $renameText)
                Button("Speichern") {
                    if let old = renamingCategory {
                        appViewModel.renameCategory(from: old, to: renameText)
                    }
                    renamingCategory = nil
                }
                Button("Abbrechen", role: .cancel) { renamingCategory = nil }
            }
            .alert("Kategorie löschen?", isPresented: Binding(
                get: { deletingCategory != nil },
                set: { if !$0 { deletingCategory = nil } }
            )) {
                Button("Löschen", role: .destructive) {
                    if let cat = deletingCategory {
                        appViewModel.deleteCategory(cat)
                    }
                    deletingCategory = nil
                }
                Button("Abbrechen", role: .cancel) { deletingCategory = nil }
            } message: {
                Text("\"\(deletingCategory ?? "")\" wird aus der Liste entfernt.")
            }
        }
    }
}
