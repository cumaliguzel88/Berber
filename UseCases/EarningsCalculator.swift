import Foundation

struct EarningsSummary {
    let totalAmount: Double
    let count: Int
}

final class EarningsCalculator {
    private let calendar = Calendar.current
    
    func daily(records: [EarningRecord], for date: Date = Date()) -> EarningsSummary {
        let filtered = records.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let total = filtered.reduce(0) { $0 + $1.amount }
        return EarningsSummary(totalAmount: total, count: filtered.count)
    }
    
    func weekly(records: [EarningRecord], for date: Date = Date()) -> EarningsSummary {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return EarningsSummary(totalAmount: 0, count: 0)
        }
        let filtered = records.filter { weekInterval.contains($0.date) }
        let total = filtered.reduce(0) { $0 + $1.amount }
        return EarningsSummary(totalAmount: total, count: filtered.count)
    }
    
    func monthly(records: [EarningRecord], for date: Date = Date()) -> EarningsSummary {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return EarningsSummary(totalAmount: 0, count: 0)
        }
        let filtered = records.filter { monthInterval.contains($0.date) }
        let total = filtered.reduce(0) { $0 + $1.amount }
        return EarningsSummary(totalAmount: total, count: filtered.count)
    }
} 