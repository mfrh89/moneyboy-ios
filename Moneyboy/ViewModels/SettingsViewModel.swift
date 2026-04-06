import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var customCategories: [String] = []

    private let key = "moneyboy_custom_categories"

    init() {
        load()
    }

    func load() {
        customCategories = UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func addCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !customCategories.contains(trimmed) else { return }
        customCategories.append(trimmed)
        save()
    }

    func renameCategory(from old: String, to new: String) {
        guard let idx = customCategories.firstIndex(of: old) else { return }
        let trimmed = new.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        customCategories[idx] = trimmed
        save()
    }

    func deleteCategory(_ name: String) {
        customCategories.removeAll { $0 == name }
        save()
    }

    private func save() {
        UserDefaults.standard.set(customCategories, forKey: key)
    }
}
