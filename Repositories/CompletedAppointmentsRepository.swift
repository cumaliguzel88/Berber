import Foundation

/// Tamamlanan randevular için ayrı repository - silindiğinde istatistiklerden kaybolmasın
protocol CompletedAppointmentsRepositoryProtocol {
    func add(_ appointment: Appointment)
    func getAll() -> [CompletedAppointment]
    func clearAll() // sadece test için
}

struct CompletedAppointment: Identifiable, Codable {
    let id: UUID
    let appointmentId: UUID // orijinal randevu ID'si
    let customerName: String
    let serviceTitle: String
    let duration: Int
    let startDate: Date
    let endDate: Date
    let completedDate: Date // tamamlanma tarihi
}

final class CompletedAppointmentsRepository: CompletedAppointmentsRepositoryProtocol {
    private let storageKey = "completed_appointments_storage_key"
    
    func add(_ appointment: Appointment) {
        guard appointment.isCompleted else { return }
        
        var all = getAll()
        
        // Aynı appointmentId ile tekrar eklenmesin
        guard !all.contains(where: { $0.appointmentId == appointment.id }) else { return }
        
        let completedAppointment = CompletedAppointment(
            id: UUID(),
            appointmentId: appointment.id,
            customerName: appointment.customerName,
            serviceTitle: appointment.service.title,
            duration: appointment.duration,
            startDate: appointment.startDate,
            endDate: appointment.endDate,
            completedDate: Date()
        )
        
        all.append(completedAppointment)
        save(all)
    }
    
    func getAll() -> [CompletedAppointment] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CompletedAppointment].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    private func save(_ records: [CompletedAppointment]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
} 