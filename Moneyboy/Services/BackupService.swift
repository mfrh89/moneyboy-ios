import Foundation
import SwiftData

enum BackupError: LocalizedError {
    case unsupportedVersion(Int)
    case decodeFailed(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedVersion(let v): return "Backup version \(v) is not supported by this app version."
        case .decodeFailed(let msg):     return "Could not read backup file: \(msg)"
        }
    }
}

struct ImportSummary {
    var inserted: Int
    var updated: Int

    var total: Int { inserted + updated }
}

enum BackupService {
    static func encode(_ items: [FinanceItem]) throws -> Data {
        let file = BackupFile(items: items)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(file)
    }

    static func decode(_ data: Data) throws -> BackupFile {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let file = try decoder.decode(BackupFile.self, from: data)
            guard file.version <= BackupFile.currentVersion else {
                throw BackupError.unsupportedVersion(file.version)
            }
            return file
        } catch let error as BackupError {
            throw error
        } catch {
            throw BackupError.decodeFailed(error.localizedDescription)
        }
    }

    static func suggestedFilename(date: Date = .now) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return "moneyboy-backup-\(df.string(from: date))"
    }
}
