import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var settingsVM = SettingsViewModel()
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var renamingCategory: String?
    @State private var renameText = ""
    @State private var showSignOutConfirm = false
    @State private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section("Benutzerkonto") {
                    if let user = authService.user {
                        LabeledContent("E-Mail", value: user.email ?? "")
                    }
                    Button("Abmelden", role: .destructive) {
                        showSignOutConfirm = true
                    }
                }

                // Categories
                Section("Kategorien") {
                    ForEach(settingsVM.customCategories, id: \.self) { cat in
                        HStack {
                            Text(cat)
                            Spacer()
                            Button {
                                renamingCategory = cat
                                renameText = cat
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Löschen", role: .destructive) {
                                settingsVM.deleteCategory(cat)
                            }
                        }
                    }
                    Button {
                        showingAddCategory = true
                    } label: {
                        Label("Kategorie hinzufügen", systemImage: "plus")
                    }
                }

                // Notifications
                Section("Benachrichtigungen") {
                    Toggle("Abo-Erinnerungen", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                Task {
                                    let granted = await NotificationService.shared.requestPermission()
                                    if granted, let uid = authService.user?.uid {
                                        NotificationService.shared.registerFCMToken(uid: uid)
                                        NotificationService.shared.scheduleSubscriptionAlerts(for: appViewModel.aboItems)
                                    } else {
                                        notificationsEnabled = false
                                    }
                                }
                            }
                        }
                }

                // Data
                Section("Daten") {
                    LabeledContent("Einträge", value: "\(appViewModel.items.count)")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Einstellungen")
            .confirmationDialog("Abmelden?", isPresented: $showSignOutConfirm) {
                Button("Abmelden", role: .destructive) { try? authService.signOut() }
                Button("Abbrechen", role: .cancel) {}
            }
            .alert("Neue Kategorie", isPresented: $showingAddCategory) {
                TextField("Name", text: $newCategoryName)
                Button("Hinzufügen") {
                    settingsVM.addCategory(newCategoryName)
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
                        settingsVM.renameCategory(from: old, to: renameText)
                    }
                    renamingCategory = nil
                }
                Button("Abbrechen", role: .cancel) { renamingCategory = nil }
            }
        }
    }
}
