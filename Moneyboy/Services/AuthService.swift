import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isLoading = true

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isLoading = false
            }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        try await updateLastLogin(uid: result.user.uid)
    }

    func register(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        try await Firestore.firestore().collection("users").document(uid).setData([
            "email": email,
            "createdAt": Timestamp(),
            "lastLogin": Timestamp()
        ])
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func updateLastLogin(uid: String) async throws {
        try await Firestore.firestore().collection("users").document(uid).setData(
            ["lastLogin": Timestamp()],
            merge: true
        )
    }
}
