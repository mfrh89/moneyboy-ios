import SwiftUI

enum AppTab: String, Hashable {
    case dashboard, wohnen, abos, analyse, whatif, settings
}

struct RootView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if authService.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if authService.user == nil {
                AuthView()
            } else {
                mainTabs
                    .task { appViewModel.subscribe(uid: authService.user!.uid) }
                    .onDisappear { appViewModel.unsubscribe() }
            }
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            Tab("Übersicht", systemImage: "chart.bar.fill", value: AppTab.dashboard) {
                DashboardView()
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
            Tab("Was wäre wenn", systemImage: "lightbulb.fill", value: AppTab.whatif) {
                WhatIfView()
            }
            Tab("Einstellungen", systemImage: "gearshape.fill", value: AppTab.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
