import SwiftUI

struct AnalyseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if appViewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Keine Daten",
                        systemImage: "chart.pie",
                        description: Text("Füge Einnahmen und Ausgaben hinzu, um die Analyse zu sehen.")
                    )
                } else {
                    FlowChartView(items: appViewModel.items)
                        .padding()
                }
            }
            .navigationTitle("Analyse")
        }
    }
}
