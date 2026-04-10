import SwiftUI

struct AnalyseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                if appViewModel.items.isEmpty {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.pie",
                        description: Text("Add income and expenses to see the analysis.")
                    )
                } else {
                    ScrollView {
                        FlowChartView(items: appViewModel.items)
                            .frame(height: 500)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .navigationTitle("Analysis")
        }
    }
}
