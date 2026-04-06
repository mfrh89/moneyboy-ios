import SwiftUI

struct SummaryTile: View {
    let title: String
    let amount: Double
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(amount.eurCompact)
                .font(.headline)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }
}
