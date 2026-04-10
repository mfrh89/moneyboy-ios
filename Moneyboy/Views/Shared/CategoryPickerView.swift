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
            categoryList
                .searchable(text: $searchText, prompt: "Search category")
                .navigationTitle("Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .alert("New Category", isPresented: $showingNewCategory) {
                    TextField("Name", text: $newCategoryName)
                    Button("Add") {
                        let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            selected = trimmed
                            dismiss()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
        }
    }

    private var categoryList: some View {
        List {
            ForEach(Array(filtered), id: \.self) { (cat: String) in
                categoryRow(cat)
            }
            Button {
                showingNewCategory = true
            } label: {
                Label("Create New Category", systemImage: "plus.circle")
            }
        }
    }

    private func categoryRow(_ cat: String) -> some View {
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
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}
