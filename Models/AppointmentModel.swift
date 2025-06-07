import Foundation

struct Appointment: Identifiable, Codable, Equatable {
    let id: UUID
    var customerName: String
    var service: Service
    var duration: Int // dakika cinsinden (30, 45, 60)
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), customerName: String, service: Service, duration: Int, startDate: Date) {
        self.id = id
        self.customerName = customerName
        self.service = service
        self.duration = duration
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .minute, value: duration, to: startDate) ?? startDate
        self.isCompleted = Date() > self.endDate
    }
    
    // Tamamlanma durumunu güncelle
    mutating func updateCompletionStatus() {
        isCompleted = Date() > endDate
    }
} 