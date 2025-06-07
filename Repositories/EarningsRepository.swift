import Foundation

protocol EarningsRepositoryProtocol {
    func add(_ record: EarningRecord)
    func getAll() -> [EarningRecord]
    func clearAll() // sadece test için
}

final class EarningsRepository: EarningsRepositoryProtocol {
    private let storageKey = "earnings_storage_key"
    
    func add(_ record: EarningRecord) {
        var all = getAll()
        // Aynı appointmentId ile tekrar eklenmesin
        guard !all.contains(where: { $0.appointmentId == record.appointmentId }) else { return }
        all.append(record)
        save(all)
    }
    
    func getAll() -> [EarningRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([EarningRecord].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    private func save(_ records: [EarningRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
} 