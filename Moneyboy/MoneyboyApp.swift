import SwiftUI
import SwiftData

@main
struct MoneyboyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: FinanceItem.self)
    }
}
