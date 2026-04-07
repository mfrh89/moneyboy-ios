import SwiftUI

struct ItemFormSheet: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    /// Pass an existing item to edit; nil = create new
    var existingItem: FinanceItem?
    /// Pre-set isWohnkosten when adding from WohnenView
    var presetWohnkosten: Bool = false

    @State private var title = ""
    @State private var amountText = ""
    @State private var type: FinanceItem.TransactionType = .expense
    @State private var category = "Wohnen"
    @State private var isFlexible = false
    @State private var isSplit = false
    @State private var isWohnkosten = false
    @State private var isSubscription = false
    @State private var subscriptionCycle: FinanceItem.SubscriptionCycle = .monthly
    @State private var nextBilling = Date()
    @State private var showCategoryPicker = false
    @State private var showDeleteConfirm = false

    private var isEditing: Bool { existingItem != nil }

    private var amount: Double { Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Typ") {
                    Picker("Typ", selection: $type) {
                        Text("Einnahme").tag(FinanceItem.TransactionType.income)
                        Text("Ausgabe").tag(FinanceItem.TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                }

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

                if isSubscription {
                    Section {
                        Picker("Zyklus", selection: $subscriptionCycle) {
                            Text("Monatlich").tag(FinanceItem.SubscriptionCycle.monthly)
                            Text("Jährlich").tag(FinanceItem.SubscriptionCycle.yearly)
                        }
                        DatePicker("Nächste Abrechnung", selection: $nextBilling, displayedComponents: .date)
                    } header: {
                        Text("Abo-Details")
                    } footer: {
                        Text("Du wirst 1 Tag vor der nächsten Abrechnung per Notification erinnert.")
                    }
                }

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
                    Button("Speichern") { save() }
                        .disabled(title.isEmpty || amount <= 0)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selected: $category)
            }
            .confirmationDialog("Eintrag löschen?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Löschen", role: .destructive) { delete() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
        .onAppear { populate() }
    }

    private func populate() {
        if presetWohnkosten && existingItem == nil {
            isWohnkosten = true
            category = "Wohnen"
            return
        }
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
        if let nb = item.subscriptionNextBilling { nextBilling = nb }
    }

    private func save() {
        let storedAmount = isSplit ? amount / 2 : amount

        if let existing = existingItem {
            existing.title = title
            existing.amount = storedAmount
            existing.type = type
            existing.category = category
            existing.isFlexible = isFlexible
            existing.isSplit = isSplit
            existing.isWohnkosten = isWohnkosten
            existing.isSubscription = isSubscription
            existing.subscriptionNextBilling = isSubscription ? nextBilling : nil
            existing.subscriptionCancellationDeadline = nil
            existing.subscriptionCycle = isSubscription ? subscriptionCycle : nil
            appViewModel.updateItem(existing)
        } else {
            let item = FinanceItem(
                title: title,
                amount: storedAmount,
                type: type,
                category: category,
                isFlexible: isFlexible,
                isSplit: isSplit,
                isWohnkosten: isWohnkosten,
                isSubscription: isSubscription,
                subscriptionNextBilling: isSubscription ? nextBilling : nil,
                subscriptionCycle: isSubscription ? subscriptionCycle : nil
            )
            appViewModel.addItem(item)
        }
        dismiss()
    }

    private func delete() {
        guard let item = existingItem else { return }
        appViewModel.deleteItem(item)
        dismiss()
    }
}
