import SwiftUI

struct CategoryPickerView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showingNewCategory = false
    @State private var newCategoryName = ""

    private var filtered: [String] {
        let all = appViewModel.availableCategories
        if searchText.isEmpty { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered, id: \.self) { cat in
                    Button {
                        selected = cat
                        dismiss()
                    } label: {
                        HStack {
                            Text(cat)
                                .foregroundStyle(.primary)
                            Spacer()
                            if cat == selected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.accentColor)
                            }
                        }
                    }
                }

                Button {
                    showingNewCategory = true
                } label: {
                    Label("Neue Kategorie anlegen", systemImage: "plus.circle")
                }
            }
            .searchable(text: $searchText, prompt: "Kategorie suchen")
            .navigationTitle("Kategorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            .alert("Neue Kategorie", isPresented: $showingNewCategory) {
                TextField("Name", text: $newCategoryName)
                Button("Hinzufügen") {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        selected = trimmed
                        dismiss()
                    }
                }
                Button("Abbrechen", role: .cancel) {}
            }
        }
    }
}
