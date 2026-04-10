import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var renamingCategory: String?
    @State private var renameText = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var deletingCategory: String?

    var body: some View {
        NavigationStack {
            List {
                Section("What If") {
                    NavigationLink {
                        WhatIfView()
                    } label: {
                        Label("Scenario Planner", systemImage: "lightbulb")
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
                        Text("Categories")
                        Spacer()
                        Button { showingAddCategory = true } label: {
                            Image(systemName: "plus")
                                .font(.body)
                        }
                    }
                }

                Section("Notifications") {
                    Toggle("Subscription Reminders", isOn: $notificationsEnabled)
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

                Section("Data") {
                    LabeledContent("Entries", value: "\(appViewModel.items.count)")
                }

                Section("Legal") {
                    Link(destination: URL(string: "https://mfrh.xyz/apps/moneyboy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "mailto:support@mfrh.xyz")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"))")
                    LabeledContent("Git", value: "\(BuildInfo.gitBranch) @ \(BuildInfo.gitCommitHash)")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("New Category", isPresented: $showingAddCategory) {
                TextField("Name", text: $newCategoryName)
                Button("Add") {
                    appViewModel.addCategory(newCategoryName)
                    newCategoryName = ""
                }
                Button("Cancel", role: .cancel) { newCategoryName = "" }
            }
            .alert("Rename", isPresented: Binding(
                get: { renamingCategory != nil },
                set: { if !$0 { renamingCategory = nil } }
            )) {
                TextField("New Name", text: $renameText)
                Button("Save") {
                    if let old = renamingCategory {
                        appViewModel.renameCategory(from: old, to: renameText)
                    }
                    renamingCategory = nil
                }
                Button("Cancel", role: .cancel) { renamingCategory = nil }
            }
            .alert("Delete Category?", isPresented: Binding(
                get: { deletingCategory != nil },
                set: { if !$0 { deletingCategory = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let cat = deletingCategory {
                        appViewModel.deleteCategory(cat)
                    }
                    deletingCategory = nil
                }
                Button("Cancel", role: .cancel) { deletingCategory = nil }
            } message: {
                Text("\"\(deletingCategory ?? "")\" will be removed from the list.")
            }
        }
    }
}
