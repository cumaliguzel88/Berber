import Foundation

final class EarningsViewModel: ObservableObject {
    @Published private(set) var dailySummary: EarningsSummary = .init(totalAmount: 0, count: 0)
    @Published private(set) var weeklySummary: EarningsSummary = .init(totalAmount: 0, count: 0)
    @Published private(set) var monthlySummary: EarningsSummary = .init(totalAmount: 0, count: 0)
    @Published private(set) var totalShaveCount: Int = 0
    @Published private(set) var earnedTrophyIndexes: [Int] = []
    
    private let repository: EarningsRepositoryProtocol
    private let calculator: EarningsCalculator
    private var allRecords: [EarningRecord] = []
    
    // Kupa ödülleri için sabitler
    let trophyMilestones: [Int] = [10, 25, 50, 80, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500]
    
    init(repository: EarningsRepositoryProtocol = EarningsRepository(), calculator: EarningsCalculator = EarningsCalculator()) {
        self.repository = repository
        self.calculator = calculator
        loadEarnings()
    }
    
    func loadEarnings() {
        allRecords = repository.getAll()
        updateSummaries()
    }
    
    func addEarningIfNeeded(for appointment: Appointment) {
        guard appointment.isCompleted else { return }
        // Zaten eklenmiş mi kontrol et
        if allRecords.contains(where: { $0.appointmentId == appointment.id }) { return }
        let record = EarningRecord(
            id: UUID(),
            appointmentId: appointment.id,
            amount: appointment.service.price,
            date: appointment.endDate, // Bitiş zamanı kazanç tarihi olarak alınır
            serviceTitle: appointment.service.title
        )
        repository.add(record)
        allRecords.append(record)
        updateSummaries()
    }
    
    func updateTrophyStatus() {
        totalShaveCount = allRecords.count
        earnedTrophyIndexes = trophyMilestones.enumerated().compactMap { index, milestone in
            totalShaveCount >= milestone ? index : nil
        }
    }
    
    private func updateSummaries() {
        dailySummary = calculator.daily(records: allRecords)
        weeklySummary = calculator.weekly(records: allRecords)
        monthlySummary = calculator.monthly(records: allRecords)
        updateTrophyStatus()
    }
    
    // Test veya reset için
    func clearAll() {
        repository.clearAll()
        allRecords = []
        updateSummaries()
    }
} 