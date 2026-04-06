import Foundation

extension Date {
    /// Short German date, e.g. "12.03.2026"
    var deShort: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.locale = Locale(identifier: "de_DE")
        return f.string(from: self)
    }

    /// Medium German date, e.g. "12. März 2026"
    var deMedium: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "de_DE")
        return f.string(from: self)
    }

    /// Days from now (negative = past)
    var daysFromNow: Int {
        Calendar.current.dateComponents([.day], from: .now, to: self).day ?? 0
    }
}
