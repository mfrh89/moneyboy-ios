import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var renamingCategory: String?
    @State private var renameText = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @State private var deletingCategory: String?

    @State private var exportDocument: BackupDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importResult: ImportSummary?
    @State private var importErrorMessage: String?

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
                    LabeledContent("Entries", value: "\(appViewModel.activeItems.count)")
                    NavigationLink {
                        TrashView()
                    } label: {
                        HStack {
                            Label("Recently Deleted", systemImage: "trash")
                            Spacer()
                            if !appViewModel.trashedItems.isEmpty {
                                Text("\(appViewModel.trashedItems.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Button {
                        prepareExport()
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
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
            .fileExporter(
                isPresented: $showingExporter,
                document: exportDocument,
                contentType: .json,
                defaultFilename: BackupService.suggestedFilename()
            ) { result in
                if case .failure(let error) = result {
                    importErrorMessage = error.localizedDescription
                }
                exportDocument = nil
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .alert(
                "Import Complete",
                isPresented: Binding(
                    get: { importResult != nil },
                    set: { if !$0 { importResult = nil } }
                )
            ) {
                Button("OK", role: .cancel) { importResult = nil }
            } message: {
                if let r = importResult {
                    Text("\(r.inserted) added, \(r.updated) updated.")
                }
            }
            .alert(
                "Import Failed",
                isPresented: Binding(
                    get: { importErrorMessage != nil },
                    set: { if !$0 { importErrorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { importErrorMessage = nil }
            } message: {
                Text(importErrorMessage ?? "")
            }
        }
    }

    private func prepareExport() {
        do {
            let data = try appViewModel.exportBackup()
            exportDocument = BackupDocument(data: data)
            showingExporter = true
        } catch {
            importErrorMessage = error.localizedDescription
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importErrorMessage = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                importResult = try appViewModel.importBackup(from: data)
            } catch {
                importErrorMessage = error.localizedDescription
            }
        }
    }
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
