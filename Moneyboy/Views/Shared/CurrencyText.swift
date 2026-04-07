import SwiftUI

/// Displays an amount in German EUR format
struct CurrencyText: View {
    let amount: Double
    var font: Font = .body

    var body: some View {
        Text(amount.eurFormatted)
            .font(font)
    }
}
