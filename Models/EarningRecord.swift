import Foundation

struct EarningRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let appointmentId: UUID
    let amount: Double
    let date: Date
    let serviceTitle: String
} 