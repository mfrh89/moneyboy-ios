import SwiftUI

struct AnalyseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                if appViewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Keine Daten",
                        systemImage: "chart.pie",
                        description: Text("Füge Einnahmen und Ausgaben hinzu, um die Analyse zu sehen.")
                    )
                } else {
                    ScrollView {
                        FlowChartView(items: appViewModel.items)
                            .frame(height: 500)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .navigationTitle("Analyse")
        }
    }
}
