import Foundation

final class ScheduleAppointmentUseCase {
    private let notificationService: NotificationServiceProtocol
    
    init(notificationService: NotificationServiceProtocol) {
        self.notificationService = notificationService
    }
    
    func execute(appointment: Appointment) {
        notificationService.scheduleNotification(for: appointment)
    }
} 