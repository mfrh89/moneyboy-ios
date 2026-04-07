import SwiftUI

enum AppTab: String, Hashable {
    case dashboard, wohnen, abos, analyse, settings
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var appViewModel = AppViewModel()
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Übersicht", systemImage: "chart.bar.fill", value: AppTab.dashboard) {
                DashboardView(selectedTab: $selectedTab)
            }
            Tab("Wohnen", systemImage: "house.fill", value: AppTab.wohnen) {
                WohnenView()
            }
            Tab("Abos", systemImage: "repeat", value: AppTab.abos) {
                AbosView()
            }
            Tab("Analyse", systemImage: "chart.pie.fill", value: AppTab.analyse) {
                AnalyseView()
            }
            Tab("Einstellungen", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView()
            }
        }
        .environmentObject(appViewModel)
        .onAppear {
            appViewModel.setup(modelContext: modelContext)
        }
    }
}
