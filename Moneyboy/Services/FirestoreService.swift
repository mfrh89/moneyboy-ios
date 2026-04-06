import Foundation
import FirebaseFirestore

@MainActor
class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    @Published var items: [FinanceItem] = []

    func subscribe(uid: String) {
        listener?.remove()
        listener = db.collection("users").document(uid).collection("items")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self, let snapshot else { return }
                self.items = snapshot.documents.compactMap {
                    FinanceItem(documentID: $0.documentID, data: $0.data())
                }
            }
    }

    func unsubscribe() {
        listener?.remove()
        listener = nil
        items = []
    }

    func addItem(uid: String, item: FinanceItem) async throws {
        let data = item.toFirestoreData()
        try await db.collection("users").document(uid).collection("items").addDocument(data: data)
    }

    func updateItem(uid: String, item: FinanceItem) async throws {
        let data = item.toFirestoreData()
        try await db.collection("users").document(uid).collection("items").document(item.id).setData(data, merge: true)
    }

    func deleteItem(uid: String, itemId: String) async throws {
        try await db.collection("users").document(uid).collection("items").document(itemId).delete()
    }
}
