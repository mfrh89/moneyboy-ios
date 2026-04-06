import SwiftUI

/// Displays an amount in German EUR format with optional color coding
struct CurrencyText: View {
    let amount: Double
    var colorCoded: Bool = false
    var font: Font = .body

    var body: some View {
        Text(amount.eurFormatted)
            .font(font)
            .foregroundStyle(colorCoded ? (amount >= 0 ? Color.green : Color.red) : Color.primary)
    }
}
