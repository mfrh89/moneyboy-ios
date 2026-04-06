import SwiftUI

struct ItemFormSheet: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    /// Pass an existing item to edit; nil = create new
    var existingItem: FinanceItem?

    @State private var title = ""
    @State private var amountText = ""
    @State private var type: FinanceItem.TransactionType = .expense
    @State private var category = "Sonstiges"
    @State private var isFlexible = false
    @State private var isSplit = false
    @State private var isWohnkosten = false
    @State private var isSubscription = false
    @State private var subscriptionCycle: FinanceItem.SubscriptionCycle = .monthly
    @State private var nextBilling = Date()
    @State private var cancellationDeadline = Date()
    @State private var showNextBilling = false
    @State private var showCancellationDeadline = false
    @State private var showCategoryPicker = false
    @State private var showDeleteConfirm = false
    @State private var isSaving = false

    private var isEditing: Bool { existingItem != nil }

    private var amount: Double { Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0 }

    var body: some View {
        NavigationStack {
            Form {
                // Type
                Section("Typ") {
                    Picker("Typ", selection: $type) {
                        Text("Einnahme").tag(FinanceItem.TransactionType.income)
                        Text("Ausgabe").tag(FinanceItem.TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                }

                // Details
                Section("Details") {
                    TextField("Bezeichnung", text: $title)
                    HStack {
                        TextField("Betrag", text: $amountText)
                            .keyboardType(.decimalPad)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Text("Kategorie")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(category)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Options
                Section("Optionen") {
                    if type == .expense {
                        Toggle("Variable Ausgabe", isOn: $isFlexible)
                        Toggle("Wohnkosten", isOn: $isWohnkosten)
                        Toggle("Geteilt (÷2)", isOn: $isSplit)
                        if isSplit {
                            HStack {
                                Text("Dein Anteil")
                                Spacer()
                                Text((amount / 2).eurFormatted)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Toggle("Abonnement", isOn: $isSubscription.animation())
                }

                // Subscription details
                if isSubscription {
                    Section("Abo-Details") {
                        Picker("Zyklus", selection: $subscriptionCycle) {
                            Text("Monatlich").tag(FinanceItem.SubscriptionCycle.monthly)
                            Text("Jährlich").tag(FinanceItem.SubscriptionCycle.yearly)
                        }
                        Toggle("Nächste Abrechnung", isOn: $showNextBilling.animation())
                        if showNextBilling {
                            DatePicker("Datum", selection: $nextBilling, displayedComponents: .date)
                        }
                        Toggle("Kündigungsfrist", isOn: $showCancellationDeadline.animation())
                        if showCancellationDeadline {
                            DatePicker("Datum", selection: $cancellationDeadline, displayedComponents: .date)
                        }
                    }
                }

                // Delete (edit mode only)
                if isEditing {
                    Section {
                        Button("Eintrag löschen", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Bearbeiten" : "Neuer Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { Task { await save() } }
                        .disabled(title.isEmpty || amount <= 0 || isSaving)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selected: $category)
            }
            .confirmationDialog("Eintrag löschen?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Löschen", role: .destructive) { Task { await delete() } }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
        .onAppear { populate() }
    }

    private func populate() {
        guard let item = existingItem else { return }
        title = item.title
        amountText = item.isSplit ? String(item.amount * 2) : String(item.amount)
        type = item.type
        category = item.category
        isFlexible = item.isFlexible
        isSplit = item.isSplit
        isWohnkosten = item.isWohnkosten
        isSubscription = item.isSubscription
        if let cycle = item.subscriptionCycle { subscriptionCycle = cycle }
        if let nb = item.subscriptionNextBilling { nextBilling = nb; showNextBilling = true }
        if let cd = item.subscriptionCancellationDeadline { cancellationDeadline = cd; showCancellationDeadline = true }
    }

    private func save() async {
        guard let uid = authService.user?.uid else { return }
        isSaving = true
        let storedAmount = isSplit ? amount / 2 : amount
        let item = FinanceItem(
            id: existingItem?.id ?? UUID().uuidString,
            title: title,
            amount: storedAmount,
            type: type,
            category: category,
            isFlexible: isFlexible,
            isSplit: isSplit,
            isWohnkosten: isWohnkosten,
            excluded: existingItem?.excluded ?? false,
            isSubscription: isSubscription,
            subscriptionNextBilling: showNextBilling ? nextBilling : nil,
            subscriptionCancellationDeadline: showCancellationDeadline ? cancellationDeadline : nil,
            subscriptionCycle: isSubscription ? subscriptionCycle : nil,
            createdAt: existingItem?.createdAt ?? Date()
        )
        do {
            if isEditing {
                try await appViewModel.updateItem(uid: uid, item: item)
            } else {
                try await appViewModel.addItem(uid: uid, item: item)
            }
            dismiss()
        } catch {
            // Show error (omitted for brevity)
        }
        isSaving = false
    }

    private func delete() async {
        guard let uid = authService.user?.uid, let item = existingItem else { return }
        try? await appViewModel.deleteItem(uid: uid, itemId: item.id)
        dismiss()
    }
}
