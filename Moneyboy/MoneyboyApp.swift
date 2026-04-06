import SwiftUI
import Firebase
import FirebaseFirestore
import UserNotifications

@main
struct MoneyboyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(appViewModel)
        }
    }

    init() {
        FirebaseApp.configure()

        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
    }
}
