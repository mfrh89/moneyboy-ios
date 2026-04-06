import Foundation

extension Double {
    /// Format as German Euro string, e.g. "1.234,56 €"
    var eurFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self) €"
    }

    /// Compact format without decimals if whole number
    var eurCompact: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "de_DE")
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        formatter.minimumFractionDigits = formatter.maximumFractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self) €"
    }
}
